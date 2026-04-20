job "haj" {
  type = "service"
  namespace = "metaspexet"

  group "haj" {

    network {
      port "hajhttp" {}
      port "imgproxyhttp" {}
    }

    task "haj" {
      service {
        name     = "haj"
        port     = "hajhttp"
        provider = "nomad"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.haj.rule=Host(`haj.metaspexet.se`)",
          "traefik.http.routers.haj.tls.certresolver=default",
        ]
      }

      driver = "docker"

      config {
        image = var.image_tag
        ports = ["hajhttp"]
      }

      template {

        data        = <<EOF
{{ with nomadVar "nomad/jobs/haj" }}
DATABASE_URL=postgres://haj:{{ .database_password }}@postgres.dsekt.internal/haj
SECRET_KEY_BASE={{ .secret_key_base }}
OIDC_SECRET={{ .oidc_secret }}
PORT={{ env "NOMAD_PORT_hajhttp" }}
API_LOGIN_SECRET={{ .api_login_secret }}
SPAM_API_KEY={{ .spam_api_key }}
IMGPROXY_KEY={{ .imgproxy_key }}
IMGPROXY_SALT={{ .imgproxy_salt }}
AWS_ACCESS_KEY_ID={{ .aws_access_key_id }}
AWS_SECRET_ACCESS_KEY={{ .aws_secret_access_key }}
{{ end }}

PHX_HOST=haj.metaspexet.se
OIDC_PROVIDER=https://sso.datasektionen.se/op
OIDC_ID=haj
OIDC_REDIRECT_URL=https://haj.metaspexet.se/login/callback
OIDC_SCOPES=openid profile email
IMAGE_URL=https://imgproxy.haj.metaspexet.se
RFINGER_API_URL=https://rfinger.datasektionen.se
RFINGER_API_KEY=super_secret
EOF
        destination = "local/.env"
        env         = true
      }
    }


    task "imgproxy" {
      service {
        name     = "imgproxy"
        port     = "imgproxyhttp"
        provider = "nomad"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.haj-imgproxy.rule=Host(`imgproxy.haj.metaspexet.se`)",
          "traefik.http.routers.haj-imgproxy.tls.certresolver=default"
        ]
      }

      driver = "docker"

      config {
        image = "ghcr.io/imgproxy/imgproxy:latest"
        ports = ["imgproxyhttp"]
      }


      template {
        data        = <<EOF
{{ with nomadVar "nomad/jobs/haj" }}
IMGPROXY_KEY={{ .imgproxy_key }}
IMGPROXY_SALT={{ .imgproxy_salt }}
IMGPROXY_BIND=:{{ env "NOMAD_PORT_imgproxyhttp" }}
AWS_ACCESS_KEY_ID={{ .imgproxy_aws_access_key_id }}
AWS_SECRET_ACCESS_KEY={{ .imgproxy_aws_secret_access_key }}
IMGPROXY_MAX_SRC_RESOLUTION=30
IMGPROXY_USE_S3=true
IMGPROXY_TTL=31536000
IMGPROXY_BASE_URL=s3://metaspexet-haj
{{ end }}
EOF
        destination = "local/.env"
        env         = true
      }
    }
  }
}

variable "image_tag" {
  type    = string
  default = "ghcr.io/datasektionen/haj:latest"
}

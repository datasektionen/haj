job "haj-dev" {
  type = "service"
  namespace = "metaspexet"

  group "haj-dev" {

    network {
      port "hajhttp" {}
      port "imgproxyhttp" {}
    }

    task "haj-dev" {
      service {
        name     = "haj-dev"
        port     = "hajhttp"
        provider = "nomad"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.haj-dev.rule=Host(`haj.betaspexet.se`)",
          "traefik.http.routers.haj-dev.tls.certresolver=default",
        ]
      }

      driver = "docker"

      config {
        image = var.image_tag
        ports = ["hajhttp"]
      }

      template {

        data        = <<EOF
{{ with nomadVar "nomad/jobs/haj-dev" }}
DATABASE_URL=postgres://haj-dev:{{ .database_password }}@postgres.dsekt.internal/haj-dev
SECRET_KEY_BASE={{ .secret_key_base }}
PORT={{ env "NOMAD_PORT_hajhttp" }}
LOGIN_API_KEY={{ .login_api_key }}
API_LOGIN_SECRET={{ .api_login_secret }}
SPAM_API_KEY={{ .spam_api_key }}
IMGPROXY_KEY={{ .imgproxy_key }}
IMGPROXY_SALT={{ .imgproxy_salt }}
AWS_ACCESS_KEY_ID={{ .aws_access_key_id }}
AWS_SECRET_ACCESS_KEY={{ .aws_secret_access_key }}
{{ end }}

PHX_HOST=haj.betaspexet.se
LOGIN_URL=http://sso.nomad.dsekt.internal/legacyapi
LOGIN_FRONTEND_URL=https://sso.datasektionen.se/legacyapi
IMAGE_URL=https://imgproxy.haj.betaspexet.se
ZFINGER_URL=https://zfinger.datasektionen.se
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
          "traefik.http.routers.haj-dev-imgproxy.rule=Host(`imgproxy.haj.betaspexet.se`)",
          "traefik.http.routers.haj-dev-imgproxy.tls.certresolver=default"
        ]
      }

      driver = "docker"

      config {
        image = "ghcr.io/imgproxy/imgproxy:latest"
        ports = ["imgproxyhttp"]
      }


      template {
        data        = <<EOF
{{ with nomadVar "nomad/jobs/haj-dev" }}
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
  default = "ghcr.io/datasektionen/haj:staging"
}

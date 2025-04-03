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
          "traefik.http.routers.haj.rule=Host(`haj.betaspexet.se`)",
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
DATABASE_URL=postgres://haj:{{ .database_password }}@postgres.dsekt.internal:5432/haj
SECRET_KEY_BASE={{ .secret_key_base }}
PORT={{ env "NOMAD_PORT_hajhttp" }}
LOGIN_API_KEY={{ .login_api_key }}
API_LOGIN_SECRET={{ .api_login_secret }}

PHX_HOST=haj.betaspexet.se
LOGIN_URL=http://sso.nomad.dsekt.internal/legacyapi
LOGIN_FRONTEND_URL=https://sso.datasektionen.se/legacyapi
IMGPROXY_KEY={{ .imgproxy_key }}
IMGPROXY_SALT={{ .imgproxy_salt }}
IMAGE_URL=https://imgproxy.haj.betaspexet.se
{{ end }}
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
          "traefik.http.routers.imgproxy.rule=Host(`imgproxy.haj.betaspexet.se`)",
          "traefik.http.routers.imgproxy.tls.certresolver=default"
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
AWS_ACCESS_KEY_ID={{ .aws_access_key_id }}
AWS_SECRET_ACCESS_KEY={{ .aws_secret_access_key }}
IMGPROXY_MAX_SRC_RESOLUTION=30
IMGPROXY_USE_S3=true
IMGPROXY_TTL=31536000
AWS_REGION=eu-north-1
IMGPROXY_BASE_URL=s3://dsekt-metaspexet-haj
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

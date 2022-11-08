## Image proxy

This is code for deploying image proxy library `imgproxy` to Fly.io to dynamically resize images.

### Env file

In the following format.

```bash
fly secrets set AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXX
fly secrets set AWS_SECRET_ACCESS_KEY=ooJioFBnsXXXXXXXXX+XXXXXX
fly secrets set IMGPROXY_KEY=XXXXX
fly secrets set IMGPROXY_SALT=XXXXXX
```
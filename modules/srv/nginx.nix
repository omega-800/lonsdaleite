{
  # https://linux-audit.com/web/nginx-security-configuration-hardening-guide/
  # https://linux-audit.com/systemd/hardening-profiles/nginx/
  /*
    https://linux-audit.com/hiding-nginx-version-number/
    # Don't show the Nginx version number (in error pages / headers)
    server_tokens off;

    If you are using a reverse proxy, you can leverage this to remove some of the headers as well. For example with Varnish you can decide to delete some of the headers by unsetting them.
    unset resp.http.X-Powered-By;
    unset resp.http.Server;
  */
}

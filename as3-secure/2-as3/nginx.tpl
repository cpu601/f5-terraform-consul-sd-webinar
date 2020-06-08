{
  "class": "AS3",
  "action": "deploy",
  "persist": true,
  "declaration": {
    "class": "ADC",
    "schemaVersion": "3.7.0",
    "id": "Consul_SD",
    "consul_sd": {
      "class": "Tenant",
      "Nginx": {
        "class": "Application",
        "template": "https",
        "serviceMain": {
          "class": "Service_HTTPS",
          "virtualPort": 8080,
          "serverTLS": "pTlsServer_Local",
          "virtualAddresses": [
            "10.0.0.200"
          ],
          "pool": "web_pool",
          "persistenceMethods": [],
          "profileMultiplex": {
            "bigip": "/Common/oneconnect"
          }
        },
        "web_pool": {
          "class": "Pool",
          "monitors": [
            "http"
          ],
          "members": [
            {
              "servicePort": 80,
              "addressDiscovery": "consul",
              "updateInterval": 10,
              "uri": "http://10.0.0.100:8500/v1/catalog/service/nginx"
            }
          ]
        },
        "pTlsServer_Local": {
          "class": "TLS_Server",
          "label": "F5-HashiCorp Demo",
          "certificates": [
              {
                "certificate": "tlsserver_local_cert"
              }
          ]
        },
        "tlsserver_local_cert": {
          "class": "Certificate",
          "certificate": ${certificate},
          "privateKey": ${privatekey}
        }
      }
    }
  }
}

# falco_kcd_cr

Este repo contiene ejemplos practicos de como configurar falco y sus plugins.

Arquitectura

![arquitectura](/img/Falco_kcd_cr.drawio.png)

## Pre-requisitos:

* Terraform
* Cuenta y credenciales para AWS, autenticarse con TF de su forma preferente. _Se incurriran en gastos, asegurarse de correr `tf destroy` al terminar_
* Requisitos para el plugin de cloudtrail se encuentran [aqui](https://github.com/falcosecurity/plugins/tree/master/plugins/cloudtrail)
* Un GH token ("full-repo scope") para la configuracion del github plugin de Falco. Más info [aquí](https://github.com/falcosecurity/plugins/tree/master/plugins/github#prerequisites)
  
## Terraform

Ver la carpeta `./terraform` y sus dos modulos:

1. `./terraform/ec2/`
2. `./terraform/cloudtrail/`

## Resultados:

![resultados](/img/falcosidekick.png)
_La UI de Falcosidekick se encontrara al digitar la ip publica de nuestra EC2, por defecto en puerto 80_

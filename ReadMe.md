# Documentation du projet

Vous trouverez un rapport plus détaillé dans le fichier "rapport.pdf" qui se trouve dans le repository git.

Nous ne savons si le projet fonctionne car nous avons des conflits avec un autre groupe qui a fait beuguer nomad et nous n'avons pas réussi a retraviller dessus depuis. Nous avons donc fait en sorte que le projet fonctionne en local chaque docker indépendamment fonctionnait mais nous n'avons pas essayer de les faire marcher ensemble. Vous trouverez donc dans ce fichier la documentation du projet et les explications de ce que nous avons fait. Dans le repository git les fichiers que nous avons ajouté sont dans le dossier "src", "conf_nomad_consul","web" et "api".

#
## Dockerfile

Les fichiers dockerfile sont écrit dans le dossier "web" pour le frontend et dans le dossier "api" pour le worker et le backend.
Nous avons eu du mal à réaliser le Dockerfile pour le backend et worker car poetry nous a donné du fil à retordre ainsi que les variables d'environnement. Nous avons eu aussi beaucoup de mal à cadrer le projet pour comprendre le nombre de Dockerfile à réaliser et quoi déployer sur chaque container.


### construction des images

Nomad a besoin d'image déja build pour pouvoir les utiliser. Pour cela, j'ai créer des images pour web et worker que j'ai mis en ligne sur un registry git en utilisant les commandes suivantes :

```bash
docker tag web ghcr.io/tototriou/web:1.0.0
docker push ghcr.io/tototriou/web:1.0.0
```

```bash
docker tag worker ghcr.io/tototriou/worker:1.0.0
docker push ghcr.io/tototriou/worker:1.0.0
```

### Commandes 

Pour lancer en local les containers il faut utiliser en se connectant en ssh sur la vm avec les commandes suivantes :

```bash
ssh -L 3000:localhost:3000 <vm>
```

```bash
docker build -t web web/
docker run -p 3000:3000 web
```
Pour le frontend par exemple.


### Script bash

dans le dossier "src", 4 scripts bash sont présents :

- launch_borie.sh : permet de reconfigurer entièrement la vm borie en clonant le git et en passant sur la bonne branch puis en copiant les fichiers de configuration nomad et consul aux bons endroits ("/etc/consul.d" et "/etc/nomad.d"),en lançant les services consul et nomad et enfin en rejoignant les cluster lié au bon datacenter.
- launch_republique.sh idem mais pour la vm république
- launch_wacken.sh idem mais pour la vm wacken
- launch_all.sh se connecte sur la vm borie et lance la commande :

```bash
nomad job run projet-cloud-virt/conf_nomad_consul/conf-nomad.hcl
```
qui permet de lancer les jobs nomad sur les vm. Il est possible dans ce script en enlevant les commentaires de lancer les 3 scripts précédants.


### Configuration nomad et consul

### Consul

J'ai récupéré la configuration consul déja présente dans le dossier consul.d de la vm partagée borie et je l'ai modifiée pour la mettre sur les vm wacken et république de la manière suivante :

pour république :

- advertise_addr = "172.16.1.25" 
- dns = "172.16.1.25"
- bootstrap_expect = 3

pour wacken :

- advertise_addr = "172.16.1.32"
- dns = "172.16.1.32"
- bootstrap_expect = 3

pour borie aucune modification n'a été faite à part le bootstrap_expect qui est passé à 3.

### Nomad

J'ai récupéré la configuration nomad déja présente dans le dossier nomad.d de la vm partagée borie et je l'ai modifiée pour la mettre sur les vm wacken et république de la manière suivante :

pour république :

```hcl
advertise {
  http = "172.16.1.25"
  rpc = "172.16.1.25"
  serf = "172.16.1.25"
}

server {
  enabled = true
  bootstrap_expect = 3
}

client {
  enabled = true
}
```

pour wacken :

```hcl
advertise {
  http = "172.16.1.32"
  rpc = "172.16.1.32"
  serf = "172.16.1.32"
}

server {
  enabled = true
  bootstrap_expect = 3
}

client {
  enabled = true
}
```

Nous avons eu un problème de regroupement des clusters avec un autre groupe qui a fait beuguer nomad et nous n'avons pas réussi a retraviller dessus depuis.
Mais avant que cela beugue, on arrivait à déployer le bon nombre de vm et de contenairs.

#
## HAproxy

Le HAproxy est la pour gérer le load balancing, d'après ce que nous avons vu, nous pouvons le déployer sur le frontend ou le backend en fonction de notre besoin. 

L'exécution de HAProxy sur Nomad permet de gérer HAProxy en tant que travail Nomad, ce qui facilite la gestion des tâches et des mises à l'échelle dans le cluster Nomad. Cela peut être utile si nous avons déjà une infrastructure basée sur Nomad et que nous souhaitons centraliser la gestion de tous les services.

L'exécution de HAProxy sur Consul tire parti des fonctionnalités de service discovery de Consul, ce qui simplifie la configuration du load balancing en utilisant les informations de service enregistrées dans Consul. Cela peut être utile si nous utilisons Consul pour la découverte des services. 

Nous avons donc décider, en fonction de là où nous en sommes dans le projet et avec le temps qu'il nous reste, de le déployer sur Consul. 

La configuration se trouve dans le fichier "haproxy.cfg"
#
## Keepalived

Keepalived est installé sur chacune des machines afin d'assurer une redondance des services en cas de pannes d'une des machines. 
La configuration est quasiment la même pour chacune des machines, et se trouve dans les fichiers nommés "keepalived_vm.conf". 

La différence qui se trouve dans ces configurations se trouve au niveau de l'état, ou nous trouvons un MASTER (la vm partagée bohrie) et deux BACKUP (les vm Republique et Wacken)

Nous utilisons l'adresse virtuelle donnée par le professeur : 172.16.3.0/16
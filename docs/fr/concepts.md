# Concepts théoriques d'une PKI

[← Retour au README](../../README.fr.md) · [Procédure technique →](procedure.md)

## Sommaire

1. [Introduction aux PKI](#1-introduction-aux-pki)
2. [Concepts fondamentaux : clés, certificats et confiance](#2-concepts-fondamentaux--clés-certificats-et-confiance)
3. [Rôles et composants d'une PKI](#3-rôles-et-composants-dune-pki)
4. [Politique et pratique de certification](#4-politique-et-pratique-de-certification)

---

## 1. Introduction aux PKI

### 1.1. Cahier des charges (mise en situation)

Dans le cadre du cours de cybersécurité (Bac 2 Cybersécurité) à l'Institut Technique Supérieur Cardinal Mercier, notre groupe a eu pour mission de concevoir et de déployer une infrastructure à clés publiques (PKI). Le projet visait à maîtriser les mécanismes fondamentaux de la confiance numérique en mettant en pratique les concepts théoriques sur une infrastructure réelle sous openSUSE Leap 15.6, avec OpenSSL et Easy-RSA.

**Objectifs du projet :**

- Comprendre et appliquer les principes cryptographiques d'une PKI
- Mettre en place une hiérarchie d'autorités de certification (Root CA et certificats finaux)
- Émettre, gérer et révoquer des certificats numériques X.509
- Distribuer les certificats et les CRL via un serveur web (Apache)
- Documenter chaque étape de façon professionnelle

**Cas d'usage réel : HTTPS.** L'usage le plus visible d'une PKI au quotidien est la sécurisation des connexions web. Chaque fois qu'un navigateur affiche un cadenas dans la barre d'adresse, une PKI est à l'œuvre en coulisses.

### 1.2. Qu'est-ce qu'une infrastructure à clés publiques ?

Une infrastructure à clés publiques, ou PKI (*Public Key Infrastructure*), est un ensemble de technologies et de règles qui permet de créer des clés cryptographiques et les certificats qui y sont associés.

Une PKI sert à sécuriser les échanges de données et à vérifier l'identité des utilisateurs, des sites web et des appareils avec lesquels on communique.

Elle repose sur une paire de clés (publique et privée) et sur des certificats délivrés par une autorité de certification (CA). La clé publique est partagée et visible par tous, alors que la clé privée doit rester secrète. Le certificat permet de s'assurer que la clé publique appartient bien à l'entité attendue. Ce système permet de chiffrer les communications et d'en garantir l'intégrité.

Les certificats assurent trois fonctions :

- **Authentification** : on communique bien avec l'entité souhaitée
- **Confidentialité** : la communication est chiffrée
- **Intégrité** : on peut détecter si les données ont été altérées pendant la transmission

### 1.3. Les enjeux de la sécurité et de la confiance numérique

Les PKI jouent un rôle essentiel dans la sécurité et la confiance numérique :

- Elles garantissent **l'authenticité** en confirmant l'identité de l'utilisateur ou du serveur avec lequel on communique.
- Elles assurent la **confidentialité** des échanges grâce au chiffrement, empêchant la lecture des données interceptées.
- Elles préservent **l'intégrité** des informations échangées, en vérifiant grâce aux signatures numériques que le contenu n'a pas été modifié.

---

## 2. Concepts fondamentaux : clés, certificats et confiance

### 2.1. La métaphore du cadenas et de la clé

Pour comprendre la cryptographie asymétrique, cœur d'une PKI, on peut utiliser l'analogie du cadenas et de la clé.

Imaginez que vous possédez un cadenas ouvert que vous pouvez distribuer librement à n'importe qui : c'est votre **clé publique**. Toute personne qui veut vous envoyer un message confidentiel le place dans une boîte et ferme votre cadenas dessus. Vous seul possédez la clé qui ouvre ce cadenas : c'est votre **clé privée**. Même la personne qui a fermé le cadenas ne peut plus ouvrir la boîte.

C'est le principe de la cryptographie asymétrique (ou cryptographie à clé publique). Contrairement à la cryptographie symétrique, où la même clé chiffre et déchiffre, deux clés mathématiquement liées jouent ici des rôles opposés et complémentaires.

### 2.2. La paire de clés : publique et privée

|                     | **Clé publique**                             | **Clé privée**                                     |
|---------------------|----------------------------------------------|----------------------------------------------------|
| **Distribution**    | Partagée librement (dans le certificat)      | Confidentielle                                     |
| **Rôle principal**  | Chiffrer un message / vérifier une signature | Déchiffrer un message / créer une signature        |
| **Analogie**        | Le cadenas ouvert (distribué à tous)         | La clé unique qui ouvre ce cadenas                 |
| **En cas de perte** | On peut régénérer une nouvelle paire         | Compromission = révocation immédiate du certificat |

### 2.3. Le certificat numérique X.509

Comment être certain que la clé publique appartient réellement à la personne ou au serveur qu'on croit contacter ? C'est là qu'intervient le certificat numérique.

Un certificat numérique est un document électronique qui associe une clé publique à une identité (personne, serveur, organisation). Il est signé numériquement par une autorité de certification, qui garantit l'authenticité de cette association. C'est l'équivalent d'une carte d'identité numérique : le nom, la photo (la clé publique) et le tampon officiel d'une autorité de confiance (la CA).

---

## 3. Rôles et composants d'une PKI

### 3.1. L'autorité de certification (CA)

Une autorité de certification est une entité de confiance au sein d'une PKI. Son rôle principal est de délivrer des certificats numériques, qui associent une clé publique à une identité vérifiée. La CA signe les certificats avec sa clé privée ; toute entité qui fait confiance à la CA peut vérifier un certificat grâce à la clé publique de celle-ci.

La CA remplit plusieurs rôles :

1. **Vérification d'identité** : s'assurer que le demandeur est bien celui qu'il prétend être.
2. **Émission des certificats** : lier la clé publique à l'identité vérifiée et signer le tout avec sa clé privée.
3. **Publication et distribution** : rendre les certificats accessibles à ceux qui doivent les utiliser.
4. **Gestion du cycle de vie** : renouvellement, et révocation des certificats compromis ou expirés. Les certificats révoqués sont publiés dans des listes de révocation (CRL), et leur statut peut être vérifié en temps réel via OCSP.
5. **Racine de confiance** : la CA constitue le point de confiance de toute la PKI.

### 3.2. L'autorité d'enregistrement (RA)

Une autorité d'enregistrement (RA) vérifie la légitimité du demandeur de certificat, à partir des informations qu'il fournit (identité, adresse, etc.). Une fois la vérification faite, la RA transmet la demande à la CA, qui délivre le certificat. Cette séparation ajoute une couche de sécurité au processus.

### 3.3. Modèles de confiance : hiérarchique ou distribué

**Architecture hiérarchique.** Structure en arbre avec, au sommet, la Root CA (autorité racine), qui est le point de confiance. En dessous se trouvent des CA intermédiaires, qui tiennent leur autorité de la racine et peuvent elles-mêmes délivrer des certificats. Tout en bas se trouvent les demandeurs de certificats. Ce modèle est simple à mettre en place et à gérer, mais il repose sur un point de confiance unique.

**Architecture distribuée.** Aucune CA ne domine la structure : plusieurs autorités se font mutuellement confiance, comme les nœuds d'un réseau pair-à-pair. Si une CA tombe, le modèle ne s'effondre pas, mais il est beaucoup plus complexe à mettre en place et à gérer.

La majorité des entreprises utilisent l'architecture hiérarchique ; le modèle distribué est réservé à des cas spécifiques.

### 3.4. Publication des certificats et gestion des répertoires

Une fois les certificats générés, la CA doit publier le certificat de la Root CA et des CA intermédiaires, les certificats finaux (utilisateurs, serveurs, etc.) et les informations de révocation (CRL ou service OCSP).

Cette publication passe par des répertoires :

- **LDAP**, un annuaire centralisé ;
- **HTTP/HTTPS**, le moyen le plus répandu et le plus accessible, pour publier les certificats de CA, les CRL et les réponses OCSP.

### 3.5. Le protocole LDAP v3

LDAP (*Lightweight Directory Access Protocol*) v3 est utilisé comme répertoire de publication dans une PKI. Il centralise la diffusion des certificats des CA, des certificats utilisateurs et des listes de révocation. Comme il est supporté par de nombreux systèmes, il facilite l'accès à ces informations.

---

## 4. Politique et pratique de certification

### 4.1. La politique de certification (CP)

Une politique de certification est un ensemble de règles qui indique l'applicabilité d'un certificat à une communauté particulière ou à une classe d'applications ayant des exigences de sécurité communes. Elle aide les parties utilisatrices à décider si un certificat est suffisamment digne de confiance pour un usage donné.

**Principaux éléments d'une CP :**

- **Identification et champ d'application** : nom, identifiant unique (OID), périmètre (types de certificats, communauté visée)
- **Niveaux de sécurité** : classification des certificats selon différents niveaux d'assurance, avec exigences minimales et usages autorisés
- **Responsabilités** : obligations de la CA, des détenteurs et des parties utilisatrices
- **Exigences opérationnelles** : durée de validité, vérification d'identité, conditions de révocation, protection des clés privées
- **Aspects juridiques** : limitations de responsabilité, résolution des litiges, conformité réglementaire (RGPD, eIDAS)

### 4.2. La déclaration des pratiques de certification (CPS)

La CPS décrit en détail les pratiques suivies par une CA pour émettre et gérer ses certificats. Elle peut être vue comme un accord entre l'organisation qui gère la CA et les personnes qui s'appuient sur ses certificats.

**Différence entre CP et CPS :**

- **CP** : document stratégique qui définit les règles et exigences générales
- **CPS** : document opérationnel qui détaille les procédures techniques de mise en œuvre de la CP

**Contenu d'une CPS :**

- **Sécurité physique** : localisation des systèmes, protection physique, contrôle d'accès, vidéosurveillance
- **Sécurité logique** : protection des clés privées, algorithmes cryptographiques, gestion des accès
- **Procédures opérationnelles** : génération des clés, vérification d'identité, émission et révocation, délais de traitement
- **Gestion du personnel** : rôles, responsabilités, formation, séparation des tâches
- **Audits et conformité** : fréquence des audits, journalisation, conservation des logs

---

*Sources : voir la [bibliographie](../bibliography.md).*

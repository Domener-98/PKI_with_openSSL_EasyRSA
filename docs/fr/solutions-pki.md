# Panorama des solutions PKI du marché

[← Retour au README](../../README.fr.md)

## 1. Microsoft : Active Directory Certificate Services (AD CS)

Microsoft propose une PKI intégrée à son écosystème avec **AD CS**. Cette solution permet de déployer une PKI interne au sein d'un domaine Active Directory et facilite la gestion des identités et des certificats dans les environnements Windows.

AD CS gère les listes de révocation (CRL), peut être associé à un service OCSP et propose des mécanismes d'automatisation comme l'auto-enrôlement des certificats, qui réduit la charge administrative.

## 2. Offres commerciales dédiées

Ces offres proposent des solutions PKI professionnelles complètes, destinées aux organisations ayant des exigences élevées en matière de sécurité, de fiabilité et de conformité réglementaire.

**CyberTrust Consulting.** Cabinet d'expertise en PKI qui accompagne les entreprises sur la stratégie, la modernisation et la conformité. Ses quatre services principaux : l'audit d'une architecture PKI existante avec feuille de route personnalisée, la conception de hiérarchies de CA (séparation des rôles, cycles de vie, niveaux d'assurance), l'automatisation du cycle de vie des certificats et la mise en conformité avec les normes internationales.

**Entrust.** Acteur majeur de la confiance numérique, qui propose des solutions de gestion complète du cycle de vie des certificats ainsi que des services d'authentification et de protection des identités, principalement pour les grandes organisations.

## 3. Solutions open source

Elles permettent de déployer une PKI sans coût de licence, avec une grande flexibilité.

**OpenPKI.** Solution complète de gestion des certificats et de leur cycle de vie, adaptée aux environnements disposant de compétences techniques spécialisées.

**IdealX.** Solutions situées entre l'open source et le commercial : plus simples à mettre en œuvre que certaines PKI open source complètes, tout en restant flexibles.

## 4. Solutions externalisées (Certplus, Verisign, etc.)

La gestion des certificats est confiée à un prestataire tiers de confiance. Cette approche est courante pour les certificats publics, notamment pour les sites web. Elle simplifie la gestion et offre un haut niveau de confiance, mais implique une dépendance au prestataire et un coût récurrent.

## 5. Critères de choix

Le choix d'une PKI dépend de la taille de l'organisation, du budget, des besoins de sécurité, des compétences internes et des contraintes réglementaires.

En pratique, les solutions open source sont souvent utilisées à des fins pédagogiques ou techniques, les solutions commerciales ou intégrées sont privilégiées en entreprise, et les solutions externalisées sont choisies quand la simplicité de gestion et la confiance publique sont prioritaires.

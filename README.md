# Blocage d'applications

Blocklist DNS pour bloquer l'accès aux applications et services suivants :

| Application | Fichier |
|-------------|---------|
| TikTok | `blocklists/apps.txt` |
| Instagram | `blocklists/apps.txt` |
| Pinterest | `blocklists/apps.txt` |
| Netflix | `blocklists/apps.txt` |
| Amazon Prime Video | `blocklists/apps.txt` |
| HBO / Max | `blocklists/apps.txt` |

## Fichiers

- `blocklists/apps.yaml` — configuration structurée par application
- `blocklists/apps.txt` — format Pi-hole / AdGuard Home (`||domain^`)
- `blocklists/hosts` — format fichier hosts (`0.0.0.0 domain`)
- `scripts/apply-hosts-block.sh` — script pour appliquer le blocage localement

## Utilisation

### Pi-hole

1. Copiez le contenu de `blocklists/apps.txt` dans **Group Management → Adlists**, ou ajoutez-le à `/etc/pihole/custom.list`
2. Rechargez la liste : `pihole -g`

### AdGuard Home

1. Allez dans **Filters → DNS blocklists → Add blocklist**
2. Collez le contenu de `blocklists/apps.txt`, ou importez le fichier

### Fichier hosts (un seul appareil)

```bash
sudo ./scripts/apply-hosts-block.sh
```

Ou ajoutez manuellement le contenu de `blocklists/hosts` à `/etc/hosts`.

### NextDNS

1. Créez une liste de blocage personnalisée
2. Importez les domaines depuis `blocklists/apps.txt` (sans le préfixe `||` et le suffixe `^`)

## Limites

- Le blocage DNS empêche l'accès via navigateur et bloque une partie du trafic des applications mobiles.
- Les applications natives (TikTok, Instagram, etc.) peuvent parfois contourner le DNS ; pour un blocage plus strict, utilisez les contrôles parentaux de l'OS (Temps d'écran iOS, Family Link Android).
- Le blocage de Prime Video cible uniquement les domaines vidéo ; `amazon.com` reste accessible pour les achats.
- HBO est désormais regroupé sous la marque **Max** (`max.com`, `hbomax.com`).

## Applications bloquées

- TikTok
- Instagram
- Pinterest
- Netflix
- Amazon Prime Video
- HBO / Max

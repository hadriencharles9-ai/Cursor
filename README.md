# Blocage horaire — TikTok, Instagram, X, Netflix, Prime Video, HBO

Bloque l'accès à ces services **de 23h à 17h** sur la machine Linux où le script est installé.  
Fenêtre autorisée : **17h00 → 22h59**.

## Services bloqués

| Service | Domaines principaux |
|---------|---------------------|
| TikTok | tiktok.com, tiktokv.com |
| Instagram | instagram.com, cdninstagram.com |
| X (Twitter) | x.com, twitter.com |
| Netflix | netflix.com, nflxvideo.net |
| Prime Video | primevideo.com |
| HBO / Max | hbo.com, hbomax.com, max.com |

## Installation

```bash
git clone <ce-repo>
cd <ce-repo>
chmod +x install.sh scripts/content-filter.sh
sudo ./install.sh
```

L'installation configure des timers systemd :

- **23h00** → activation du blocage
- **17h00** → désactivation du blocage
- **Au démarrage** → synchronisation automatique selon l'heure

## Fonctionnement

Le blocage utilise le fichier `/etc/hosts` : les domaines listés sont redirigés vers `0.0.0.0`.

```bash
sudo content-filter.sh status    # État actuel
sudo content-filter.sh block     # Forcer le blocage
sudo content-filter.sh unblock    # Forcer le déblocage
sudo content-filter.sh sync       # Appliquer selon l'heure
```

## Limites

- **Machine locale uniquement** : ce blocage s'applique à l'ordinateur où il est installé, pas au réseau entier.
- **Applications mobiles** : les apps sur téléphone ne sont pas affectées.
- **Contournement possible** : un VPN ou le DNS `1.1.1.1` peut contourner le blocage `/etc/hosts`.
- **Apps natives** : certaines apps desktop peuvent utiliser des domaines CDN supplémentaires.

Pour un blocage réseau plus robuste (routeur, Pi-hole), adaptez la liste `config/domains.txt` à votre solution DNS.

## Personnalisation

- **Domaines** : éditez `config/domains.txt`, puis réinstallez ou copiez le fichier vers `/usr/local/share/content-filter/domains.txt`.
- **Horaires** : modifiez les fichiers `systemd/content-filter-*.timer`, puis exécutez `sudo systemctl daemon-reload`.

## Désinstallation

```bash
sudo content-filter.sh unblock
sudo systemctl disable --now content-filter-block.timer content-filter-unblock.timer content-filter-sync.service
sudo rm -f /usr/local/bin/content-filter.sh
sudo rm -rf /usr/local/share/content-filter
sudo rm -f /etc/systemd/system/content-filter-*
sudo systemctl daemon-reload
```

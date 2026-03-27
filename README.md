# Reticulum GHCR image (reticulum-pep)

This repository builds and publishes a Docker image containing the Reticulum `rns` package and utilities. The image is intended to be consumed from GHCR (GitHub Container Registry) so users can pull and run the daemon without building or running python locally.

## Published image

- Image name: `ghcr.io/cleanshooter/reticulum-pep:<tag>` (also pushed as `:latest`)

## Examples

- Run the daemon with a named Docker volume (cross-platform, recommended):

```bash
docker volume create reticulum-data
docker run --rm -it \
	-v reticulum-data:/home/rnsuser/.reticulum \
	ghcr.io/cleanshooter/reticulum-pep:latest
```

- Run with a host bind mount (Linux / WSL / macOS):

```bash
mkdir -p ./reticulum-data
# ensure permissions for the container user if needed
docker run --rm -it \
	-v $(pwd)/reticulum-data:/home/rnsuser/.reticulum \
	ghcr.io/cleanshooter/reticulum-pep:latest
```

- Run detached and view logs:

```bash
docker run -d --name reticulum -v reticulum-data:/home/rnsuser/.reticulum ghcr.io/cleanshooter/reticulum-pep:latest
docker logs -f reticulum
```

- Pass arguments to `rnsd` (ENTRYPOINT is `rnsd`):

```bash
docker run --rm -it -v reticulum-data:/home/rnsuser/.reticulum ghcr.io/cleanshooter/reticulum-pep:latest --service
```

Docker Compose example

```yaml
version: '3.8'
services:
	reticulum:
		image: ghcr.io/cleanshooter/reticulum-pep:latest
		volumes:
			- reticulum-data:/home/rnsuser/.reticulum
		restart: unless-stopped

volumes:
	reticulum-data:
```

## Contributing

- If you want to improve the image (interfaces, additional utilities, config defaults), open a PR.

## Support & Notes

- The container runs `rnsd` as a non-root `rnsuser`. The entrypoint ensures the config directory is writable when using named volumes and common bind-mount workflows.
- If you need local development with a source checkout, I can add a `Dockerfile.dev` that copies local source into the image for iterative testing.

Questions or want me to add a `docker-compose.override.yml` example? Open a PR or tell me what example you prefer and I’ll add it.

## Next Steps

1. Pre-configure the node for transport and add backbone gateway interface. Provide guide and example on how to get this working through docker/k8 on most servers
2. I want to automate adding interfaces to other online backbone popualted on https://directory.rns.recipes/. This should make netowrk growth more automatic/organic. This need to preserve any custom interfaces while dynamically adding trustworth ones and rebooting the node to use the new interfaces.
3. Develop a trustworthy node profile. Is it useing a current version of Reticulum? Is it online? Is it buggin out like we saw the network do on March 26th? I saw someone use fail2ban to automate some of this on thier node and block traffic from nodes that had been attacked or were attacking. While integrating somethign like fail2ban may work at an individual node level I'm wondering if we simply need a better way to use Reticulum tools that already exist. My best guess is that there isn't a great community blackhole list. If there is I've seen no mention of where it is for the public ret.
4. Investigate establshing a credible source for a blackhole list (https://markqvist.github.io/Reticulum/manual/using.html#automated-list-sourcing). Publish blackhole lists (https://markqvist.github.io/Reticulum/manual/using.html#publishing-blackhole-lists) from nodes created by this project and encourage people to share their identity via PR to this project once they are up and operating. If we can automate the creating of the blackhole list through open profiling rules that everyone can agree to and apply these rules to multiple public nodes that each node can subscribe to we should be able to systematically reduce attack vectors to the public ret. (At least it sounds good in my head this late at night.)

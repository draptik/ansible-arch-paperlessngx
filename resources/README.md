# Restic

Validate, that the systemd timer is actived on the target system:

```sh
systemctl list-timers
```

The output should contain `backup-paperless.timer`.

# unms_backups_to_git
ubiquity UNMS

# edgerouter
# edge switch

UNMS polls devices for changes and makes backups locally on UNMS, also makes backups of it's own UNMS configs.
All unms backups while appearing to be binary data are intact tar.gz files, so we extrace those files to get a diff while also backing up the original so we can restore it directly to a device without UNMS if needed.

This script grabs those backups via running on a 15 minute cron 

note: probably could shorten the cron if you wanted as UNMS picks up changes pretty frequently but i wouldn't advise it be any shorter than 5 minutes as i think that would create collisions.

# cloudfoundry-conjur-buildpack

## How it works ?

Make sure PCF is running and has the meta-buildpack installed `https://github.com/cf-platform-eng/meta-buildpack`:

For easy testing without a Conjur instance running. Uncomment the `VCAP_SERVICES` in `./lib/0000_retrieve-secrets.sh` and `./bin/decorate`

Upload `cloudfoundry-conjur-buildpack`

```
./upload
```

Run the test application

```
cd test_app
cf push test_app
```

Get the test app route at

```
cf app test_app | grep routes | awk '{ print $2 }'
```

Visit the test app URL and observe that environment variables have been filled in.

---

SSH into the test app

```
cf ssh test_app
```

Then run `env` and observe that there are no environment variables leaked from the application.

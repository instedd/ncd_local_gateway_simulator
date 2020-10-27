# NCD local gateway simulator

Local gateway simulator to stress test NCD.

Available as Docker image [instedd/lgwsim](https://hub.docker.com/r/instedd/lgwsim)

## Usage

Create executable by running:

```
shards build --release
```

Run:

```
bin/lgwsim
```

## Usage with InSTEDD cloud

You need to create a QST server channel in order to use this application. The easiest way is to [simulate a lgw registration](https://code.google.com/archive/p/nuntium/wikis/Tickets.wiki).

1. Get a 4-digit registration code

```
$ curl -d "address=12341234" https://nuntium-stg.instedd.org/tickets.json
{"code":"5244","secret_key":"32a2a8ed-****-****-****-************","status":"pending","data":{"address":"12341234"}}
```

2. Create a QST server (local gateway) from an InSTEDD Application

3. Enter the 4-digit registration code: `5244`

4. Get the generated

```
$ curl "https://nuntium-stg.instedd.org/tickets/5244.json?secret_key="32a2a8ed-****-****-****-************""
{"code":"5244","secret_key":"32a2a8ed-****-****-****-************","status":"complete","data":{"address":"12341234","channel":"my_qst_simulator","account":"manas","password":"Ji******","message":null}}
```

5. Lauch a QST Simulator with the above configuration

```
$ docker run --rm -it -e HOST=nuntium-stg.instedd.org -e ACCOUNT=manas -e CHANNEL_NAME=my_qst_simulator -e CHANNEL_PASSWORD=Ji****** instedd/lgwsim
```

6. Start sending messages from the InSTEDD Application

## Behaviour

For each message received, if a reply is sent, it will be according to de following rules

| Input | Reply |
|-|-|
| `#oneof:A,B,C` | `A` or `B` or `C` |
| `#numeric:N-M` | a number between `N` and `M` |

The following environment variables controls other aspects of the behavior

| Variable | Default | Description |
|-|-|-|
| `SLEEP_SECONDS` | 10 | How much time to wait between fetches from the QST server |
| `NO_REPLY_PERCENT` | 0.2 | Percent of respondents that never reply |
| `DELAY_REPLY_PERCENT` | 0.2 | Percent of respondents that have a delay in their reply |
| `DELAY_REPLY_MIN_SECONDS` | 0 | Of the above, minimum time in seconds of that delay (min..max) |
| `DELAY_REPLY_MAX_SECONDS` | 60 | Of the above, maximum time in seconds of that delay (min..max) |
| `INCORRECT_REPLY_PERCENT` | 0.2 | Percent of respondents that reply an incorrect answer |
| `STICKY_RESPONDENTS` | true | If true, once a respondent replies, it will always reply |


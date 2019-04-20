# ExMessageBus

## TL DR'

```
# in the parent directory

docker-compose up -d

docker-compose exec ex /bin/bash

```

```
iex -S mix

# in the console drop a message into the stream

ExMessageBus.MessageBus.Stream.add("MyEvent", %{body: "stream", subject: "ciao"})

# the processing worker will fetch the message and print output to screen
```

you can also post to the stream from redis-cli

```
redis-cli

XADD pn_message_bus * name MyEvent payload "{}"
```

malformed events will cause genserver to crash but should recover properly

in this implementation the consumer ACKs messages instantly after fetching them and BEFORE parsing

you can see any pending messages for the group with

```
XPENDING pn_message_bus ex_mb

# example

XADD pn_message_bus * name MyEvent payload "asdfdsaf"

XPENDING pn_message_bus ex_mb

# should still return 0 meaning that malformed events will be discarded
```

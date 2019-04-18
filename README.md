# rabbitmq-queue-info

This is a proof-of-concept RabbitMQ plugin that allows to list queue
parameters in an alternative way than [RabbitMQ Management plugin](https://www.rabbitmq.com/management.html).

Currently the plugin returns only `name` and `messages_ready` queue parameters.
It can be modified in [`rabbit_queue_info_worker`](./src/rabbit_queue_info_worker.erl)
module.

Once the plugin is up and running it exposes HTTP `/list_queues` endpoint on port `8000`.
Additionaly, it is possible to use query string `max_len=$X` to filter out queues that
has `messages_ready` greater than `$X`.

**The plugin was tested with RabbitMQ 3.7.8 in both single and multi node installations.**

### Building the plugin tarball

In order to build a tarball with the plugin run:

`make dist`

The command produces the tarball and places it under `$PROJECT_ROOT/plugins` directory.

The tarball is ready to be deployed on a RabbitMQ node.

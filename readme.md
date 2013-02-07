#Queue
## Initialize
    Viki::Queue.new('queue.dev.viki.io', 80)

It defaults to localhost queues.

## Subscribe
Before being able to consume from a queue, you must first subscribe to some resources:

    q = Viki::Queue.new('queue.dev.viki.io', 80)
    q.subscribe('gaia-applications', ['application', 'user'])

This creates a queue named *gaia_applications* which will monitor the *application* and *user* resources.

## Unsubscribe
You can unsubscribe from some resources:

    q.unsubscribe('gaia-applications', ['application'])

This leaves a queue named *gaia_applications* which only monitors the *application* resource.

## Deletion
You can delete a queue and all of its queued events:

    q = Viki::Queue.new('queue.dev.viki.io', 80)
    q.delete('gaia_applications')

#Messages
## Writing
Use the `create_message`, `update_message` and `delete_message` methods:

    q = Viki::Queue.new('queue.dev.viki.io', 80)
    q.create_message(:application, '38a')
    q.update_message(:user, '9003u')
    q.delete_message(:container, '50c')

An optional payload parameter can be supplied:

    q.create_message(:application, '38a', {name: 'gaia'})

### Bulk write
Multiple events can be sent at once:

    q = Viki::Queue.new('queue.dev.viki.io', 80)
    q.bulk([:create, :video, '1v'], [:update, :user, '1u', 'optional_payload'], [:delete, :container, '1c'])

The events will be queued in-order.

## Consumption

Consumption involves using the built-in runner and providing a routing class:

    Class GaiaRouter
      def self.delete_application(event)
        # do something
        true
      end
      def self.error(error)
        # handle
      end
    end
    Viki::Queue::Runner.run(QUEUE_NAME, GaiaRouter)

The method names look like `ACTION_RESOURCE`, where `ACTION` can be `create`, `update` or `delete`. The `RESOURCE` should be the same as what the queue was regitered for. There's no need to `close` the queue, simply return true when the event has been successfully processed.

`run` takes a 3rd optional argument to configure the runner, possible values are:

* host: the hostname of the queue server
* port: the port of the queue server
* iterations: the number of iterations to run, 0 means loop forever (DEFAULT 1)
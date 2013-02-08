#Installation
    gem install queue_client

#Queue

## Configuration
    Viki::Queue.configure do |config|
      config.host = "queue.dev.viki.io"
      config.port = "5672"
    end

It defaults to localhost queues.

## Initialize
    queue_service = Viki::Queue.service

## Subscribe
Before being able to consume from a queue, you must first subscribe to some resources:

    queue_service.subscribe('gaia-applications', ['application', 'user'])

This creates a queue named *gaia_applications* which will monitor the *application* and *user* resources, i.e. it will subscribe to `resources.application.#` and `resources.user.#`. It is possible to change the root of the route path by using the `.route(new_route)` command as described below (see *routing*).

## Unsubscribe
You can unsubscribe from some resources:

    queue_service.unsubscribe('gaia-applications', ['application'])

This leaves a queue named *gaia_applications* which only monitors the *application* resource, i.e. it will subscribe to `resources.application.#`. It is possible to change the root of the route path by using the `.route(new_route)` command as described below (see *routing*).

## Deletion
You can delete a queue and all of its queued events:

    queue_service.delete('gaia_applications')

## Routing
By default, all the messages will be routed under `resources.RESOURCE_NAME.ACTION`, e.g. `resources.videos.create`.It is possible to modify the root of the route.

    queue_service.route('delayed_jobs.subbing')
    queue_service.create_message(:compile, '3v')

This commands will create a message under the route `delayed_jobs.subbing.compile.create`.

On the other hand, by default subscriptions are routed via `resources.RESOURCE_NAME.#`, e.g. `resources.videos.#`.

    queue_service.route('services.gaia')
    queue_service.subscribe('gaia-consumer', [users, apps])

This will create a new queue called `gaia-consumer` that is subscribed to `services.gaia.apps.#`.

*Note* that the part `.resource.action` is always present in both examples, changing the route only affects the root of it.

#Messages

  Messages have always the following structure:

    action: mandatory, it will always be 'create', 'update' or 'delete'
    resource: mandatory
    id: mandatory
    payload: optional attribute.

## Writing
Use the `create_message`, `update_message` and `delete_message` methods:

    queue_service.create_message(:application, '38a')
    queue_service.update_message(:user, '9003u')
    queue_service.delete_message(:container, '50c')

An optional payload parameter can be supplied:

    queue_service.create_message(:application, '38a', {name: 'gaia'})

This will create a message in the queue that looks like:

    {action: 'create', resource: 'application', id: '38a', payload: {name: 'gaia'} }

### Bulk write
Multiple events can be sent at once:

    queue_service.bulk([:create, :video, '1v'], [:update, :user, '1u', 'optional_payload'], [:delete, :container, '1c'])

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
    queue_service.run(QUEUE_NAME, GaiaRouter)

The method names look like `ACTION_RESOURCE`, where `ACTION` can be `create`, `update` or `delete`. The `RESOURCE` can be any resource. *Note* that if noone is registered for listening the kind of resource you are sending, the message will just be dropped.There's no need to `close` the queue, simply return true when the event has been successfully processed. *Note* that a message is only acknowledged to the queue when the processing method returns true.

If an exception is raised while processing the message, the runner will call the error method of the router with the exception. Afterwards, the runner will wait before trying to reprocess the same message again.

`run` takes a 3rd optional argument to configure the runner, possible values are:

* `iterations`: The number of iterations to run, i.e. of messages to process. 0 means loop forever (DEFAULT 1).
* `fail_pause`: Seconds to pause until trying to reprocess a failed message (DEFAULT 10)

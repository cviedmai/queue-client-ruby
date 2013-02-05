#Queue
## Configuration
    Viki::Queue.configure do |c|
      c.host = 'queue.dev.viki.io'
      c.port = 80
    end
It defaults to production queues!

## Creation
Before being able to consume from a queue, you must first create it:

    Viki::Queue.create('gaia_applications', ['application', 'user'])

This creates a queue named *gaia_applications* which will monitor the *application* and *user* resources. An error is raised on failure

## Deletion
You can delete a queue an all the events that are queued:

    Viki::Queue.delete('gaia_applications')

#Events
## Writing
Use the `create`, `update` and `delete` methods. An exception will be raised on failure.

    Viki::Queue::Event.create(:application, '38a')
    Viki::Queue::Event.update(:user, '9003u')
    Viki::Queue::Event.delete(:container, '50c')

### Bulk write
It is possible to do a bulk write of multiple events.

    Viki::Queue::Event::Bulk([:create, :video, '1v'], [:update, :user, '1u'], [:delete, :container, '1c'])

The events will be writen in the order that they appear on the parameters.

## Consumption
Queues' events can be consumed in one of two ways.

### Poll-close
The first is more manual and relies on the `poll` and `close` methods:

    event = Viki::Queue::Event.poll(QUEUE_NAME)
    unless event.nil?
      # do something
      Viki::Queue::Event.close(QUEUE_NAME)
    end

**Note that `poll` blocks for 10 seconds and returns nil if no events are queued on timeout**

### Runner
The other approach involves a using the built-in runner and providing a routing class:

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

* iterations: the number of iterations to run, 0 means loop forever (DEFAULT 1)
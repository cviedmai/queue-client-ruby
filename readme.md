## Configuration
    Viki::Queue.configure |c|
      c.host = 'queue.dev.viki.io'
      c.port = 80
    end
It defaults to production queues!

## Writing
Use the `create`, `update` and `delete` methods. An exception will be raised on failure

    Viki::Queue.create(:application, '38a')
    Viki::Queue.update(:user, '9003u')
    Viki::Queue.delete(:container, '50c')

## Queue creation
Before being able to consume from a queue, you must first create it:

    Viki::Queue.register('gaia_applications', ['application', 'user'])

This creates a queue named *gaia_applications* which will monitor the *application* and *user* resources. An error is raised on failure

## Consumption
Queues can be consumed in one of two ways. The first is more manual and relies on the `poll` and `close` methods:

    event = Viki::Queue.poll(QUEUE_NAME)
    unless event.nil?
      # do something
      Viki::Queue.close(QUEUE_NAME)
    end

**Note that `poll` blocks for 10 seconds and returns nil if no events are queued on timeout**

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
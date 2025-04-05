import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

import { MarksmithController, ListContinuationController } from '@avo-hq/marksmith'

application.register('marksmith', MarksmithController)
application.register('list-continuation', ListContinuationController)

export { application }

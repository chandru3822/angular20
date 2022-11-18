import moment from 'moment-timezone'
import {NamedTimeZoneImpl, createPlugin} from '@fullcalendar/core'

class MomentNamedTimeZone extends NamedTimeZoneImpl {
  offsetForArray(a) {
    return moment.tz(a, this.timeZoneName).utcOffset()
  }
  timestampToArray(ms){
    return moment.tz(ms, this.timeZoneName).toArray()
  }
}

export default createPlugin({
  namedTimeZonedImpl: MomentNamedTimeZone
})

import { getRequestWithParams } from '@/helpers/helpers'

export async function getEventResourceFields(eventId) {
  const params = { eventId }
  return await getRequestWithParams(`/customFieldGroup/getEventResourceFields`, { params } )
}

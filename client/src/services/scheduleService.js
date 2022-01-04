import { getRequest } from '@/helpers/helpers'

export async function getEventTypes() {
  return await getRequest(`/eventType`)
}

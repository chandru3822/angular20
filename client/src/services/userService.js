import { getRequest } from '@/helpers/helpers'

export async function getUserStatusTypes() {
  return await getRequest(`/user/statuses`)
}

export async function getUserProfileDefaultFields() {
  return await getRequest(`/defaultField/userProfile`)
}





import { deleteRequest } from '@/helpers/helpers'

export async function deleteAttachment(id) {
  return await deleteRequest(`/attachment/${id}`)
}

import {deleteRequest} from '@/helpers/helpers'

export async function deleteAttachment(id) {
  try {
    const {data} = await deleteRequest(`/attachment/${id}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}





import { postRequestWithRequestParams } from '@/helpers/helpers'

export async function saveContact(contactId, body) {
  let params = {
    contactId
  }
  return await postRequestWithRequestParams(`/contact/custom`, body, params)
}






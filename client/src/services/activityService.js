import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getHashtags() {
  return await getRequest(`/hashtag`)
}

export async function getNoteHashtags() {
  return await getRequest(`/hashtag/note`)
}

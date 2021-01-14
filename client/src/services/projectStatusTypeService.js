import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getCompanyProjectStatusTypes(projectId) {
  try {
    let params = {
      projectId
    }
    const {data} = await getRequestWithParams(`/project/companyStatus`, { params })
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getProjectStatusTypes() {
  //these are at the root level
  try {
    const {data} = await getRequest(`/project/status`)
    return {data, status}
  } catch (e) {
    throw e
  }
}


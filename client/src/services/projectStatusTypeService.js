import { getRequest, getRequestWithParams } from '@/helpers/helpers'

export async function getCompanyProjectStatusTypes(projectId) {
  let params = { projectId }
  return await getRequestWithParams(`/project/companyStatus`, { params })
}

export async function getProjectStatusTypes() {
  //these are at the root level
  return await getRequest(`/project/status`)
}

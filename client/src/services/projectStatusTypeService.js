import { getRequest, getRequestWithParams } from '@/helpers/helpers'

export async function getCompanyProjectStatusTypes(projectId) {
  let params = { projectId }
  return await getRequestWithParams(`/project/companyStatus`, { params })
}

export async function getProjectStatusTypes() {
  //these are at the root level
  return await getRequest(`/project/status`)
}

export function getStatusColor(rootTypeId) {
  //1 active, 2 cancelled, 3 on hold, 4 complete
  return rootTypeId === 1 ? 'green' : rootTypeId === 2 ? '#8B0000' : rootTypeId === 3 ? 'yellow' : 'cornflowerblue'
}

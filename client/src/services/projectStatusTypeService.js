import { getRequest, getRequestWithParams } from '@/helpers/helpers'

export async function getCompanyProjectStatusTypes(projectId) {
  let params = { projectId }
  return await getRequestWithParams(`/project/companyStatus`, {
    skipCancel: true,
    params }, null, [])
}

export async function getProjectStatusTypes() {
  //these are at the root level
  return await getRequest(`/project/status`)
}

export function getStatusColorClass(rootTypeId) {
  //1 active, 2 cancelled, 3 on hold, 4 complete
  return rootTypeId === 1 ? 'success--text' : rootTypeId === 2 ? 'error--text' : rootTypeId === 3 ? 'warning--text' : 'cornflowerblue'
}

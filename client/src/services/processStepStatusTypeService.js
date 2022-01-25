import { getRequest, getRequestWithParams } from '@/helpers/helpers'

export async function getCompanyStatusTypes(projectId, projectProcessStepId) {
  const params = { projectId, projectProcessStepId }
  return await getRequestWithParams(`/processStep/status/company`, { params })
}

export async function getAvailableForProcessStep(processStepId) {
  return await getRequest(
    `/processStep/status/company/availableForProcessStep/${processStepId}`
  )
}

export async function getActiveAssignedToProcessStep(processStepId) {
  return await getRequest(
    `/processStep/status/company/activeAssignedToProcessStep/${processStepId}`
  )
}

export function getStatusClass(rootTypeId) {
  return rootTypeId === 1 ? 'status-active' : rootTypeId === 2 ? 'status-complete' : 'status-cancelled'
}

export async function getAssignedToProcessStep(processStepId) {
  return await getRequest(
    `/processStep/status/assignedToProcessStep/${processStepId}`,
    null,
    []
  )
}

export async function getCompanyAssignedToProcessStep(processStepId) {
  return await getRequest(
    `/processStep/status/company/assignedToProcessStep/${processStepId}`,
    null,
    []
  )
}

export async function getCancelledCompanyStatusTypesAssignedToProcessStep(
  processStepId
) {
  return await getRequestWithParams(
    `/processStep/status/company/cancelledAssignedToProcessStep/${processStepId}`, null, null, []
  )
}

export async function getCancelledCompanyStatusTypes(
  projectId,
  projectProcessStepId
) {
  const params = { projectId, projectProcessStepId }
  return await getRequestWithParams(`/processStep/status/company/cancelled`, {
    params,
  })
}

// these are the root status types
export async function getStatusTypes(projectId, projectProcessStepId) {
  const params = { projectId, projectProcessStepId }
  return await getRequestWithParams(`/processStep/status`, { params }, null, [])
}

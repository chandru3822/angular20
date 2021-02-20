import {getRequestWithParams, getRequest} from '@/helpers/helpers'

export async function getCompanyStatusTypes(projectId, projectProcessStepId) {
  try {
    let params = {
      projectId,
      projectProcessStepId
    }
    const {data} = await getRequestWithParams(`/processStep/status/company`, { params })
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getAvailableForProcessStep(processStepId) {
  try {
    const {data} = await getRequest(`/processStep/status/company/availableForProcessStep/${processStepId}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getActiveAssignedToProcessStep(processStepId) {
  try {
    const {data} = await getRequest(`/processStep/status/company/activeAssignedToProcessStep/${processStepId}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getAssignedToProcessStep(processStepId) {
  try {
    const {data} = await getRequest(`/processStep/status/company/assignedToProcessStep/${processStepId}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getCancelledCompanyStatusTypesAssignedToProcessStep(processStepId) {
  try {
    const {data} = await getRequestWithParams(`/processStep/status/company/cancelledAssignedToProcessStep/${processStepId}`)
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getCancelledCompanyStatusTypes(projectId, projectProcessStepId) {
  try {
    let params = {
      projectId,
      projectProcessStepId
    }
    const {data} = await getRequestWithParams(`/processStep/status/company/cancelled`, { params })
    return {data, status}
  } catch (e) {
    throw e
  }
}

// these are the root status types
export async function getStatusTypes(projectId, projectProcessStepId) {
  try {
    let params = {
      projectId,
      projectProcessStepId
    }
    const {data} = await getRequestWithParams(`/processStep/status`, { params })
    return {data, status}
  } catch (e) {
    throw e
  }
}



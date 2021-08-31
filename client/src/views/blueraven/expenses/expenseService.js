import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getBudgetTypes() {
  try {
    const {data, status} = await getRequest(`/expenseBudgets/budgetTypes`, 'blueraven')
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getGlCodes() {
  try {
    const {data, status} = await getRequest(`/expenses/glCodes`, 'blueraven')
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getUsersWithBudget() {
  try {
    const {data, status} = await getRequest(`/expenseBudgets/usersWithBudget`, 'blueraven')
    return {data, status}
  } catch (e) {
    throw e
  }
}

export async function getReimbursementRequestImage(requestId) {
  try {
    const {data, status} = await getRequest(`/reimbursement/request/${requestId}/image`, 'blueraven')
    return {data, status}
  } catch (e) {
    throw e
  }
}





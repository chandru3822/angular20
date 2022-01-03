import { getRequest } from '@/helpers/helpers'

export async function getBudgetTypes() {
  return await getRequest(`/expenseBudgets/budgetTypes`, 'blueraven')
}

export async function getGlCodes() {
  return await getRequest(`/expenses/glCodes`, 'blueraven')
}

export async function getUsersWithBudget() {
  return await getRequest(`/expenseBudgets/usersWithBudget`, 'blueraven')
}

export async function getReimbursementRequestImage(requestId) {
  return await getRequest(
    `/reimbursement/request/${requestId}/image`,
    'blueraven'
  )
}

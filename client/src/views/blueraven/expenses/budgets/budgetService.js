import {getRequest, getRequestWithParams} from '@/helpers/helpers'

export async function getBudgetTypes() {
  try {
    const {data, status} = await getRequest(`/expenseBudgets/budgetTypes`, 'blueraven')
    return {data, status}
  } catch (e) {
    throw e
  }
}





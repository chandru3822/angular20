import { getRequest } from '@/helpers/helpers'

export async function getCommissionPlans(positionId) {
  return await getRequest(`/commissionManagement/plans/${positionId}`, 'blueraven', [])
}






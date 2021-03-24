import { getRequestWithParams, postRequest } from '@/helpers/helpers'

export async function getCloserAreas (userId, setterOverride) {
  const requestBody = {userId, setterOverride}
  const {data} = await postRequest('/closerDashboard/getAreas', requestBody, 'blueraven')
  return data
}

export async function getCloserRegions (userId, areas, setterOverride) {
  const requestBody = {userId, areas, setterOverride}
  const {data} = await postRequest('/closerDashboard/getRegions', requestBody, 'blueraven')
  return data
}

export async function getCloserDistricts (userId, areas, regions, setterOverride) {
  const requestBody = {userId, areas, regions}
  const {data} = await postRequest('/closerDashboard/getDistricts', requestBody, 'blueraven')
  return data
}


export async function getCloserOffices (userId, areas, regions, districts, setterOverride) {
  const requestBody = {userId, areas, regions, districts, setterOverride}
  const {data} = await postRequest('/closerDashboard/getOffices', requestBody, 'blueraven')
  return data
}

export async function getCloserReps (userId, areas, regions, districts, offices) {
  const requestBody = {userId, areas, regions, districts, offices}
  const {data} = await postRequest('/closerDashboard/getReps', requestBody, 'blueraven')
  return data
}

export async function getSetterDistricts (userId) {
  const params = {userId}
  const {data} = await getRequestWithParams('/setterDashboard/getDistricts', {params}, 'blueraven')
  return data
}

export async function getSetterRegions (userId, districts) {
  districts = encodeURI(districts)
  const params = {userId, districts}
  const {data} = await getRequestWithParams('/setterDashboard/getRegions', {params}, 'blueraven')
  return data
}

export async function getSetterOffices (userId, regions) {
  regions = encodeURI(regions)
  const params = {userId, regions}
  const {data} = await getRequestWithParams('/setterDashboard/getOffices', {params}, 'blueraven')
  return data
}

export async function getSetterReps (userId, regions, offices) {
  const requestBody = {userId, regions, offices}
  const {data} = await postRequest('/setterDashboard/getReps', requestBody, 'blueraven')
  return data
}

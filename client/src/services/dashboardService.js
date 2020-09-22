import { getRequestWithParams, postRequest } from '@/helpers/helpers'

export async function getCloserDistricts (userId, setterOverride) {
  const params = {userId, setterOverride}
  const {data} = await getRequestWithParams('/closerDashboard/getDistricts', {params}, 'blueraven')
  return data
}

export async function getCloserRegions (userId, districts, setterOverride) {
  districts = encodeURI(districts)
  const params = {userId, districts, setterOverride}
  const {data} = await getRequestWithParams('/closerDashboard/getRegions', {params}, 'blueraven')
  return data
}

export async function getCloserOffices (userId, regions, setterOverride) {
  regions = encodeURI(regions)
  const params = {userId, regions, setterOverride}
  const {data} = await getRequestWithParams('/closerDashboard/getOffices', {params}, 'blueraven')
  return data
}

export async function getCloserReps (userId, regions, offices) {
  const requestBody = {userId, regions, offices}
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

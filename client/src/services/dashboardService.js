import { postRequest } from '@/helpers/helpers'

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

export async function getCloserDistricts (userId, areas, regions) {
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

export async function getSetterAreas (userId) {
  const requestBody = {userId}
  const {data} = await postRequest('/setterDashboard/getAreas', requestBody, 'blueraven')
  return data
}

export async function getSetterRegions (userId, areas) {
  const requestBody = {userId, areas}
  const {data} = await postRequest('/setterDashboard/getRegions', requestBody, 'blueraven')
  return data
}

export async function getSetterDistricts (userId, areas, regions) {
  const requestBody = {userId, areas, regions}
  const {data} = await postRequest('/setterDashboard/getDistricts', requestBody, 'blueraven')
  return data
}

export async function getSetterOffices (userId, areas, regions, districts) {
  const requestBody = {userId, areas, regions, districts}
  const {data} = await postRequest('/setterDashboard/getOffices', requestBody, 'blueraven')
  return data
}

export async function getSetterReps (userId, areas, regions, districts, offices) {
  const requestBody = {userId, areas, regions, districts, offices}
  const {data} = await postRequest('/setterDashboard/getReps', requestBody, 'blueraven')
  return data
}

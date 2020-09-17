import { getRequestWithParams, postRequest } from '@/helpers/helpers'

export async function getCloserDistricts (userId, setterOverride) {
  const params = {userId, setterOverride}
  const {data} = await getRequestWithParams('/closerDashboard/getDistricts', {params}, 'blueraven')

  if (data?.length > 0) {
    data.forEach(dataItem => {
      dataItem.value = dataItem.org_id
      dataItem.text = dataItem.org_name
    })
  }

  return data
}

export async function getCloserRegions (userId, districts, setterOverride) {
  districts = encodeURI(districts)
  const params = {userId, districts, setterOverride}
  const {data} = await getRequestWithParams('/closerDashboard/getRegions', {params}, 'blueraven')

  if (data?.length > 0) {
    data.forEach(dataItem => {
      dataItem.value = dataItem.org_id
      dataItem.text = dataItem.org_name
    })
  }

  return data
}

export async function getCloserOffices (userId, regions, setterOverride) {
  regions = encodeURI(regions)
  const params = {userId, regions, setterOverride}
  const {data} = await getRequestWithParams('/closerDashboard/getOffices', {params}, 'blueraven')

  if (data?.length > 0) {
    data.forEach(dataItem => {
      dataItem.value = dataItem.org_id
      dataItem.text = dataItem.org_name
    })
  }

  return data
}

export async function getCloserReps (userId, regions, offices) {
  const requestBody = {userId, regions, offices}
  const {data} = await postRequest('/closerDashboard/getReps', requestBody, 'blueraven')

  if (data?.length > 0) {
    data.forEach(dataItem => {
      dataItem.value = dataItem.user_id
      dataItem.text = dataItem.name
    })
  }

  return data
}

export async function getSetterDistricts (userId) {
  const params = {userId}
  const {data} = await getRequestWithParams('/setterDashboard/getDistricts', {params}, 'blueraven')

  data.forEach(dataItem => {
    dataItem.value = dataItem.org_id
    dataItem.text = dataItem.org_name
  })

  return data
}

export async function getSetterRegions (userId, districts) {
  districts = encodeURI(districts)
  const params = {userId, districts}
  const {data} = await getRequestWithParams('/setterDashboard/getRegions', {params}, 'blueraven')

  data.forEach(dataItem => {
    dataItem.value = dataItem.org_id
    dataItem.text = dataItem.org_name
  })

  return data
}

export async function getSetterOffices (userId, regions) {
  regions = encodeURI(regions)
  const params = {userId, regions}
  const {data} = await getRequestWithParams('/setterDashboard/getOffices', {params}, 'blueraven')

  data.forEach(dataItem => {
    dataItem.value = dataItem.org_id
    dataItem.text = dataItem.org_name
  })

  return data
}

export async function getSetterReps (userId, regions, offices) {
  const requestBody = {userId, regions, offices}
  const {data} = await postRequest('/setterDashboard/getReps', requestBody, 'blueraven')

  data.forEach(dataItem => {
    dataItem.value = dataItem.user_id
    dataItem.text = dataItem.name
  })

  return data
}

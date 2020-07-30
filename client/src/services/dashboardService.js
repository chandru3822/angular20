import {getRequestWithParams} from '@/helpers/helpers'

export async function getDistricts (userId, userLine, setterOverride) {
  try {
    const params = {userId, userLine, setterOverride}
    const {data} = await getRequestWithParams('/closerDashboard/districts', {params}, 'blueraven')

    data.forEach(dataItem => {
      dataItem.id = dataItem.org_id
      dataItem.label = dataItem.org_name
    })

    return data
  } catch (e) {
    throw e
  }
}

export async function getRegions (userId, districts, userLine, setterOverride) {
  try {
    const params = {userId, districts, userLine, setterOverride}
    const {data} = await getRequestWithParams('/closerDashboard/regions', {params}, 'blueraven')

    data.forEach(dataItem => {
      dataItem.id = dataItem.org_id
      dataItem.label = dataItem.org_name
    })

    return data
  } catch (e) {
    throw e
  }
}

export async function getOffices (userId, regions, userLine, setterOverride) {
  try {
    const params = {userId, regions, userLine, setterOverride}
    const {data} = await getRequestWithParams('/closerDashboard/offices', {params}, 'blueraven')

    data.forEach(dataItem => {
      dataItem.id = dataItem.org_id
      dataItem.label = dataItem.org_name
    })

    return data
  } catch (e) {
    throw e
  }
}

export async function getReps (userId, offices, userLine, setterOverride) {
  try {
    const params = {userId, offices, userLine, setterOverride}
    const {data} = await getRequestWithParams('/closerDashboard/users', {params}, 'blueraven')

    data.forEach(dataItem => {
      dataItem.id = dataItem.org_id
      dataItem.label = dataItem.org_name
    })

    return data
  } catch (e) {
    throw e
  }
}

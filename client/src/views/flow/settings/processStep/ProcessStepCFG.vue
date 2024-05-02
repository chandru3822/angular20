<template>
<v-container class="custom-field-group-container py-0">
	<v-row>
		<v-col cols="12" class="py-0">
			<ProcessStepCustomFieldGroups
				v-if="!loading"
				:customFieldGroups="processStep.customFieldGroups"
				@status-updated="updateStatus"
				@default-collapse-updated="toggleCollapseByDefault"
				@order-updated="updateOrder"
			/>
		</v-col>
	</v-row>
</v-container>
</template>

<script setup>

import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
import { handleHidingGlobalLoader, getRequest, putRequest, logError } from '@/helpers/helpers'
import { computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute} from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'
import cloneDeep from 'lodash.clonedeep'

const appStore = useAppStore()
const route = useRoute()
const userStore = useUserStore()

const loading = ref( true)
const processStep = ref({})
const breadcrumbs = ref([{
	text: 'Back',
	disabled: false,
	exact: true,
	to: `/settings/processSteps`
}])

const processStepId = computed(() => route.params.id)

const userCanEdit = computed(() => userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT'))
const companyId = computed(() => userStore.details.companyId)

const originalCustomFieldGroups = ref([])

onMounted(async () => {
	await getProcessStepDetails()
})

const getProcessStepDetails = async () => {
	appStore.loading = true
	loading.value = true
	try {
		const {data, status} = await getRequest(`/processStep/${processStepId.value}`)
		processStep.value = data
		originalCustomFieldGroups.value = cloneDeep(data.customFieldGroups)
		loading.value = false
		handleHidingGlobalLoader(status)
	} catch (e) {
		logError(e)
		appStore.showSnack('ERROR', 'Error Retrieving Data')
		appStore.loading = false
	}
}

const updateStatus = async (group) => {
	try {
		appStore.loading = true
		const {data, status} = await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
		const index = processStep.value.customFieldGroups.findIndex(g => g.id === group.id)
		processStep.value.customFieldGroups[index] = data
		originalCustomFieldGroups.value = cloneDeep(processStep.value.customFieldGroups)
		// vue doesn't watch nested props, so force prop update to child component
		processStep.value = cloneDeep(processStep.value)
		appStore.showSnack('SUCCESS', 'Status updated')
		handleHidingGlobalLoader(status)
	} catch (e) {
		logError(e)
		appStore.showSnack('ERROR', 'Error updating status')
		appStore.loading = false
		//revert to previous status
		processStep.value.customFieldGroups = cloneDeep(originalCustomFieldGroups.value)
		processStep.value = cloneDeep(processStep.value)
	}
}

const toggleCollapseByDefault = async (group) => {
	try {
		appStore.loading = true
		const {data, status} = await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
		const index = processStep.value.customFieldGroups.findIndex(g => g.id === group.id)
		processStep.value.customFieldGroups[index] = data
		originalCustomFieldGroups.value = cloneDeep(processStep.value.customFieldGroups)
		// vue doesn't watch nested props, so force prop update to child component
		processStep.value = cloneDeep(processStep.value)
		appStore.showSnack('SUCCESS', 'Collapse default updated')
		handleHidingGlobalLoader(status)
	} catch (e) {
		logError(e)
		appStore.showSnack('ERROR', 'Error updating collapse default')
		appStore.loading = false
		//revert to previous status
		processStep.value.customFieldGroups = cloneDeep(originalCustomFieldGroups.value)
		processStep.value = cloneDeep(processStep.value)
	}
}

const updateOrder = () => getProcessStepDetails()
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}
</style>

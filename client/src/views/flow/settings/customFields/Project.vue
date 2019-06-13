<template>
  <v-layout row wrap>
    <v-flex xs-12>
        <v-data-table
            :items="customFields"
            hide-actions
            hide-headers
            class="elevation-1"
            item-key="id"
            expand
        >
          <template slot="items" slot-scope="props">
            <tr v-if="props.item.name !== 'Add Field'" :class="{ 'shaded-row': props.index % 2 }">
              <td class="text-xs-right">{{ props.item.name }}</td>
              <td class="">
                <v-btn>Edit</v-btn>
                <v-icon>delete</v-icon>
              </td>
            </tr>
            <tr v-else>
              <td class="text-xs-right">
                <v-btn>
                  <v-icon>add</v-icon>
                  Add Field
                </v-btn>
              </td>
              <td></td>
            </tr>
          </template>
        </v-data-table>
    </v-flex>
  </v-layout>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import { getRequest } from '@/helpers/helpers'

export default {
  name: 'Project',
  data () {
    return {
      customFields: [
        {
          id: 1,
          name: '1 Testing'
        },
        {
          id: 2,
          name: '2 Testing'
        },
        {
          id: 3,
          name: '3 Testing'
        },
        {
          id: 4,
          name: '4 Testing'
        },
        {
          id: null,
          name: 'Add Field'
        }
      ]
    }
  },
  created () {
    this.getCustomFields (1)
  },
  computed: {
  },
  methods: {
    async getCustomFields (typeId) {
      // todo: unhard code company id and type id
      const resp = await getRequest(`/api/v1/flow/customField/listByType`, { params: { typeId, companyId: 1 }})
      console.log('resp', resp)
    }
  }
}
</script>

<style scoped lang="scss">

</style>

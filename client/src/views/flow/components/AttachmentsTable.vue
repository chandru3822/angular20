<template>
  <v-simple-table dense>
    <tbody>
    <tr v-for="item in drillDownAttachments"  class="text-left"  :class="{'primary-row': item.main}" :key="item.processStepId">
      <td class="text-left">
        <v-btn
            width="100%"
            icon
            text
            :href="item.presignedUrl" class="type">
          <v-icon large color="grey">
            {{ getIconForFile(item) }}
          </v-icon>
        </v-btn>
      </td>
      <td class="type text-left">
        {{item.editableName}}
      </td>
      <td>{{ item.uploadedBy ? `${item.uploadedBy}, ` : ''}}{{item.dateCreated | formatDate('timestamp', 'MM/DD/YYYY')}}</td>
    </tr>
    </tbody>
  </v-simple-table>
</template>

<script>
import {getFileIcon} from "@/helpers/helpers";

export default {
  name: "AttachmentsTable",
  props: {
    attachments: Array,
    displayType: Object,
    showNonPrimaryDocs: Boolean
  },
  computed: {
    drillDownAttachments () {
      if (this.displayType === null) {
        return []
      } else {
        if (this.showNonPrimaryDocs) {
          return this.attachments.filter(a => !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId)
        }
        else {
          return this.attachments.filter(a => !a.archived && a.attachmentTypeId === this.displayType.attachmentTypeId && a.main)
        }
      }
    }
  },
  methods: {
    getIconForFile (item) {
      return getFileIcon(item)
    }
  }
}
</script>

<style scoped>
.v-btn:before {
  display: none;
}

</style>

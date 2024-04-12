<template>
  <v-container>

    <vue-html2pdf
        :show-layout="false"
        :float-layout="true"
        :enable-download="true"
        :preview-modal="true"
        :paginate-elements-by-height="1400"
        filename="nightprogrammerpdf"
        :pdf-quality="2"
        :manual-pagination="false"
        pdf-format="a4"
        :pdf-margin="10"
        pdf-orientation="portrait"
        pdf-content-width="800px"
        @progress="onProgress($event)"
        ref="html2Pdf"
    >
      <section slot="pdf-content">
        <div>
          <v-row>
            <v-col cols="6" xl="4" lg="4" md="3" v-for="(user,index) of users">
              <v-card style="background-color: #f6f7f8; border: 1px solid grey;">
                <v-list-item>
                  <v-list-item-avatar
                      tile
                      width="100"
                      height="100"
                  >
                    <img width="10"
                         height="10" alt="user-image" v-if="user.imageUrl" :src="user.imageUrl"/>
                    <img v-else :src="require('../../../assets/flow/user_img_placeholder.png')"/>

                  </v-list-item-avatar>
                  <v-list-item-content>
                    {{ user.firstName }} {{ user.lastName }}<br/>
                    {{ user.position }}
                  </v-list-item-content>
                </v-list-item>
              </v-card>
            </v-col>
          </v-row>


        </div>
      </section>
    </vue-html2pdf>
    <v-row>
      <v-col cols="6" xl="4" lg="4" md="3" v-for="(user,index) of users">
        <v-card>
          <v-list-item>
            <v-list-item-avatar
                tile
                width="100"
                height="100"
            >
              <v-img name="userImg" alt="user-image" v-if="user.imageUrl" :src="user.imageUrl"></v-img>
              <v-img name="userImg" v-else :src="require('../../../assets/flow/user_img_placeholder.png')"></v-img>

            </v-list-item-avatar>
            <v-list-item-content>
              {{ user.firstName }} {{ user.lastName }}<br/>
              {{ user.position }}
            </v-list-item-content>
          </v-list-item>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import {getRequestWithParams} from '@/helpers/helpers'
import VueHtml2pdf from "vue-html2pdf";
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'

const props = defineProps({
  users: [],
  userDetails: [],
  headers: [],
  usersPerPage: Number,
  startingUser: Number,
  endingUser: Number
})
const { users, userDetails, headers, usersPerPage, startingUser, endingUser } = toRefs(props)

const cardText = ref("Hi!")
const userImage = ref({})
const loadComplete = ref(false)
const dataLoading = ref(true)
const totalUsers = ref(0)
const currentPage = ref(1)
const filters = ref({search: '',firstName: '',lastName: '',email: '',phone: '',orgs: {},statuses: [],positions: []})
const options = ref({itemsPerPage: 100})
const source = ref(null)
const masterOrgFilterList = ref([])
const html2Pdf = ref(null)

const getUserImages = async() => {
  let userIds = [];
  for (let user of userDetails.value) {
    userIds.push(user.id);
  }
  userIds = encodeURI(userIds);
  let params = {
    sourceIds: userIds,
    attachmentTypeId: 9
  }

  const {data} = await getRequestWithParams('/attachment/getAttachmentPresignedUrlsForUserList', {params})

  if (data) {
    userDetails.value?.forEach(user => {
      if (user.id && data[user.id]) {
        user.imageUrl = data[user.id]
      }

      if (user.imageUrl) {
        user.userImageAltText = 'Photo of ' + user.name + ', a Blue Raven Solar employee'
      } else {
        user.userImageAltText = 'User photo placeholder'
      }
    })
  }
}
const hasGenerated = () => {
  alert("PDF generated successfully!")
}
const generatePDF = () => {
  html2Pdf.value.generatePdf();
}
</script>

<style scoped>

</style>

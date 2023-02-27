<template>
  <v-container>
    <v-row>
      <v-col cols="3" v-for="(user,index) of users" v-if="index >= startingUser && index < endingUser">
        <v-card>
          <v-list-item>
            <v-list-item-avatar
              tile
              width="100"
              height="100"
            >
              <v-img name="userImg" alt="user-image" v-if="user.imageUrl"  :src="user.imageUrl"></v-img>
              <v-img name="userImg" v-else :src="require('../../../assets/flow/user_img_placeholder.png')"></v-img>

            </v-list-item-avatar>
            <v-list-item-content>
              {{user.firstName}} {{user.lastName}}<br/>
              {{user.position}}
            </v-list-item-content>
          </v-list-item>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import axios from "axios";
import cloneDeep from "lodash.clonedeep";
import max from "lodash.max";
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, logError, getRequestWithParams} from '@/helpers/helpers'
import {getOrgFilters} from '@/services/orgService'


export default {
  name: "UserImages",
  data() {
    return {
      cardText: "Hi!",
      userImage: {},
      loadComplete: false,
      dataLoading: true,
      totalUsers: 0,
      currentPage: 1,
      filters: {
        search: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        orgs: {},
        statuses: [],
        positions: []
      },
      options: {
        itemsPerPage: 100
      },
      source: null,
      masterOrgFilterList: [],
    }
  },
  props: {
    users: [],
    userDetails: [],
    headers: [],
    usersPerPage: Number,
    startingUser: Number,
    endingUser: Number
  },
  created () {

  },
  methods: {
    async getUserImages () {
      let userIds = [];
      for(let user of this.userDetails){
        userIds.push(user.id);
      }
      userIds = encodeURI(userIds);
      let params = {
        sourceIds: userIds,
        attachmentTypeId: 9
      }

      const {data} = await getRequestWithParams('/attachment/getAttachmentPresignedUrlsForUserList', {params})

      if (data) {
        this.userDetails.forEach(user => {
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
    },


  }
}
</script>

<style scoped>

</style>

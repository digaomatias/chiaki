/*
 * This file is part of Chiaki.
 *
 * Chiaki is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Chiaki is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Chiaki.  If not, see <https://www.gnu.org/licenses/>.
 */

#ifndef CHIAKI_HOST_H
#define CHIAKI_HOST_H

#include <string>
#include <map>
#include <netinet/in.h>

#include <chiaki/log.h>
#include <chiaki/regist.h>
#include <chiaki/discovery.h>
#include <chiaki/opusdecoder.h>
#include <chiaki/controller.h>

#include "exception.h"
#include "io.h"

#ifdef CHIAKI_ENABLE_SWITCH_OVERCLOCK
#define OC_1785 1785000000
#define OC_1580 1580000000
#define OC_1326 1326000000
#define OC_1220 1220000000
#define OC_1020 1020000000
#endif

class DiscoveryManager;
static void Discovery(ChiakiDiscoveryHost*, void*);
static void Regist(ChiakiRegistEvent*, void*);
static void InitAudio(unsigned int channels, unsigned int rate, void * user);
static bool Video(uint8_t * buf, size_t buf_size, void * user);
static void Audio(int16_t * buf, size_t samples_count, void * user);

class Host
{
	private:
		ChiakiLog *log = NULL;
		//video config
		ChiakiVideoResolutionPreset video_resolution = CHIAKI_VIDEO_RESOLUTION_PRESET_720p;
		ChiakiVideoFPSPreset video_fps = CHIAKI_VIDEO_FPS_PRESET_60;
#ifdef CHIAKI_ENABLE_SWITCH_OVERCLOCK
		int cpu_overclock = OC_1326;
#endif
		// info from discovery manager
		int system_version = 0;
		int device_discovery_protocol_version = 0;
		std::string host_type;
		// user info
		std::string psn_online_id = "";
		std::string psn_account_id = "";
		// info from regist/settings
		std::string ap_ssid;
		std::string ap_bssid;
		std::string ap_key;
		std::string ap_name;
		std::string ps4_nickname;
		// mac address = 48 bits
		uint8_t ps4_mac[6] = {0};
		char rp_regist_key[CHIAKI_SESSION_AUTH_SIZE] = {0};
		uint32_t rp_key_type = 0;
		uint8_t rp_key[0x10] = {0};
		// manage stream session
		ChiakiSession session;
		ChiakiOpusDecoder opus_decoder;
		ChiakiConnectVideoProfile video_profile;
		ChiakiControllerState keyboard_state;
		friend class DiscoveryManager;
		friend class Settings;
	public:
		// internal state
		ChiakiDiscoveryHostState state = CHIAKI_DISCOVERY_HOST_STATE_UNKNOWN;
		bool discovered = false;
		bool registered = false;
		// rp_key_data is true when rp_key, rp_regist_key, rp_key_type
		bool rp_key_data = false;
		std::string host_name;
		// sony's host_id == mac addr without colon
		std::string host_id;
		std::string host_addr;
		// share picture frame
		// with main function
		Host(ChiakiLog *log):log(log) {};
		Host(){};
		bool GetVideoResolution(int * ret_width, int * ret_height);
		int Register(std::string pin);
		int Wakeup();
		int ConnectSession(IO *);
		void StartSession();
		void SendFeedbackState(ChiakiControllerState*);
		void RegistCB(ChiakiRegistEvent*);
};

#endif

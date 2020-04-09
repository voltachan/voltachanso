local open_id = "XXXXX"
--openid 请在账户信息中查看

local app_key = "XXXXX"
--appKey 请在我的接口中查看

--请务必完成上面的填写，否则无法使用


local json = require "cjson.safe"
local curl=require("lcurl.safe")

script_info = {
  title = "V搜",
  description = "更新时间：2020年4月9日18:23:10",
  version = "0.0.3"
}

local  filetype = {
  Video = {
    "wmv",
    "rmvb",
    "mpeg4",
    "mpeg2",
    "flv",
    "avi",
    "3gp",
    "mpga",
    "qt",
    "rm",
    "wmz",
    "wmd",
    "wvx",
    "wmx",
    "wm",
    "mpg",
    "mp4",
    "mkv",
    "mpeg",
    "mov",
    "asf",
    "m4v",
    "m3u8",
    "swf"
  },
  Music = {
    "wma",
    "wav",
    "mp3",
    "aac",
    "ra",
    "ram",
    "mp2",
    "ogg",
    "aif",
    "mpega",
    "amr",
    "mid",
    "midi",
    "m4a",
    "flac"
  },
  Img = {
    "jpg",
    "jpeg",
    "gif",
    "bmp",
    "png",
    "jpe",
    "cur",
    "svgz",
    "ico"
  },
  Rar = {
    "rar",
    "zip",
    "7z",
    "iso"
  },
  Exe = {"exe"},
  Ipa = {"ipa","plist","ipsw"},
  Apk = {"apk"},
  Txt = {"txt", "rtf"},
  Xls = {"xls", "xlsx"},
  Doc = {"doc", "docx"},
  Ppt = {"ppt", "pptx"},
  Pdf = {"pdf"},
  Vsd = {"vsd"},
  Torrent = {"torrent"},
  CAD = {
    "dwg",
    "dws",
    "dwt",
    "dxf"
  }
}
function gettype(data)
  local tmp
  tmp=string.gsub(data, "{c.-}(.-){/c}", "%1")
  tmp = string.reverse(tmp)
  if string.find(tmp,"%.")~=nil then
    return string.reverse(string.sub(tmp,1,string.find(tmp,"%.")-1))
  end
  return ""
end
function getIcon(isdir, type)
  local icon="Other"
  if isdir and (type==nil or type=='') then
    icon = "Folder"
  end
  for id, allkind in pairs(filetype) do
    for _, now in pairs(allkind) do
      if now == type then
        icon = tostring(id)
        break
      end
    end
  end
  return "icon/FileType/Middle/"..icon.."Type.png"
end
function onSearch(key, page)
  if app_key=="XXXXX" or open_id=="XXXXX" then
    pd.logInfo("请在插件中输入申请的app_key和open_id！")
    local r={}
    table.insert(r, {
      ["url"] = "",
      ["title"] = "{c #ff0000}请在插件中输入申请的app_key和open_id！{/c}",
      ["time"] = os.date("%Y-%m-%d %H:%M", os.time()),
      ["showhtml"] = "true",
      ["tooltip"] = "请在插件中输入申请的app_key和open_id！",
      ["icon_size"] = "28,28",
      ["image"] = getIcon(true),
    })
    return r
  end
  local request_body = "appKey="..app_key.."&openId="..open_id.."&highlight=1&t=down&o=1&q="..key.."&pageSize=25&currentPage="..page
  local r = ""
	local c = curl.easy{
		url = "https://api.xiaocongjisuan.com/data/skydriverdata/get",
		httpheader = header,
		postfields=request_body,
		ssl_verifyhost = 0,
		ssl_verifypeer = 0,
		followlocation = 1,
		timeout = 15,
		proxy = pd.getProxy(),
		writefunction = function(buffer)
			r = r .. buffer
			return #buffer
		end,
	}
	local _, e = c:perform()
	c:close()
return parse(r)
end
function onItemClick(item)
  return ACT_SHARELINK, item.url
end
function parse(data)
  local title,tooltip,urlget
  local result = {}
  local j = json.decode(data)
  if j.errorCode~=0 then
  if ret2==10005 then
    table.insert(result, {
      ["url"] = "",
      ["title"] = "{c #ff0000}请关闭IP白名单！{/c}",
      ["time"] = os.date("%Y-%m-%d %H:%M", os.time()),
      ["showhtml"] = "true",
      ["tooltip"] = "请关闭IP白名单！",
      ["icon_size"] = "28,28",
      ["image"] = getIcon(true),
    })
    pd.logInfo("请关闭IP白名单！")
    else
    table.insert(result, {
      ["url"] = "",
      ["title"] = "{c #ff0000}发生错误："..j.errorMessage.."{/c}",
      ["time"] = os.date("%Y-%m-%d %H:%M", os.time()),
      ["showhtml"] = "true",
      ["tooltip"] = "发生错误："..j.errorMessage,
      ["icon_size"] = "28,28",
      ["image"] = getIcon(true),
    })
    pd.logInfo("发生错误："..j.errorMessage)
    end
    return result
    end
    local ret1,ret2=pcall(function(j) return j == nil or j.data.result == nil or j.data.result == json.null end,j)
    if ret1 then
    if ret2 then
        return result
    end
    else
        return result
    end
  for _, item in pairs(j.data.result) do
    title = item.title
    tooltip = string.gsub(title, "<span.-red'>(.-)</span>", "%1")
    title = string.gsub(title, "<span.-red'>(.-)</span>", "{c #ff0000}%1{/c}")
    urlget = item.url
    if type(item.password)==string then
    if string.len(item.password)==4 then
      urlget = urlget .. " " .. item['password']
    end
    end
    table.insert(result, {
      ["url"] = urlget,
      ["title"] = title,
      ["time"] = os.date("%Y-%m-%d %H:%M", string.sub(item.shareTime, 1,10 )),
      ["showhtml"] = "true",
      ["tooltip"] = tooltip,
      ["check_url"] = "true",
      ["icon_size"] = "28,28",
      ["image"] = getIcon(item.isDir == "1", gettype(title)),
    })
  end
  return result
end
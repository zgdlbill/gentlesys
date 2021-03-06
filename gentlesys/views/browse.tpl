<!DOCTYPE html>
<html>
<head>
   <meta charset="utf-8">
   <meta name="viewport" content="width=device-width,initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
   <meta name="description" content="Gentlesys {{.Title}}"/>
   <title>Gentlesys {{.Title}}</title>
   <link rel="stylesheet" href="http://apps.bdimg.com/libs/bootstrap/3.2.0/css/bootstrap.min.css">
   <script src="http://apps.bdimg.com/libs/jquery/2.1.4/jquery.min.js"></script>
   <script src="http://apps.bdimg.com/libs/bootstrap/3.2.0/js/bootstrap.min.js"></script>
   <script src="/static/bootsp/edt/kindeditor-all-min.js"></script>
   <script src="/static/bootsp/edt/lang/zh-CN.js"></script>
   <style>
	h4 {
    color:#4876FF;
    }
	.key-prob {
		color:#0000CC;
		padding-right:2px;
	}
	.comment-css {
	background-color:#e0ffff;
	}
	.body-css {
	 background-color:#fcfdf8;
	}
	</style>
</head>
<body style="padding-top:55px;">
{{str2html .Navigation}}
<div class="container-fluid">
<div class="row">

<div class="col-md-6 col-md-offset-1">
    <p class="crumbs"><a href="/">首页</a> &gt;<a href="{{.HrefSub}}">{{.SubName}}</a>&gt;<a href="/article{{.Args}}">[我要发帖]</a></p>
    <h4 class="text-center">{{.Title}}</h4>
    <p><span class="key-prob"><a href="{{.HrefToSub}}">{{.Type}}</a></span>
    <span class = "key-prob"><a href="/user?name={{.UserName}}">{{.UserName}}</a></span>
    <span class = "key-prob">{{.Date}}</span></p>

    <div id="story" class="body-css">
        {{str2html .Story}}
        
    </div>
   
    <div class="body-css">
    <ul class="pagination pagination-sm">
        <li><span class="btn btn-default" role="button">网友回复</span></li>
    	<li><a href="{{.PrePage}}">&laquo;</a></li>
    	 {{range .RecordIndexs}}
        	<li class="{{.IsActive}}"><a href="{{.Ref}}">{{.Title}}</a></li>
    	{{end}}
    	<li><a href="{{.NextPage}}">&raquo;</a></li>
    </ul>
    {{range .Comments}}
       <p class="comment-css"><span>#{{.Id}}楼 </span><a href="/user?name={{.UserName}}">{{.UserName}}</a>&nbsp;&nbsp;{{.Time}} <a class="btn-sm" href="#write" onclick="test({{.UserName}},{{.Id}})">回复</a></p>
       {{if isdeled .}}
       <p>#内容已被屏蔽</p>
       {{else}}
       <p>{{str2html .Content}}</p>
       <p>{{str2html .Answer}}</p>
       {{end}}
        <button type="button" class="btn btn-link pull-right" onclick="praise({{.Id}},{{.Praise}})">
          <span class="glyphicon glyphicon-thumbs-up"></span><span id="c{{.Id}}"> {{.Praise}}</span>
        </button>
       <h5 class="page-header" style="margin-top:30px;margin-bottom:10px;"></h5>
    {{end}}
   
    {{if .NoMore}}
    <hr />
    <p>没有更多留言了...</p>
    {{end}}

    <ul class="pagination pagination-sm">
        <li><span class="btn btn-default" role="button">网友回复</span></li>
    	<li><a href="{{.PrePage}}">&laquo;</a></li>
    	 {{range .RecordIndexs}}
        	<li class="{{.IsActive}}"><a href="{{.Ref}}">{{.Title}}</a></li>
    	{{end}}
    	<li><a href="{{.NextPage}}">&raquo;</a></li>
    </ul>
    </div>

    <script>
    function praise(id,times){
		$.ajax({
		          async:true,
		          cache:false,
		          timeout:10000,
		          type:"POST",
		          url:"/praise",
		          data:{
		          	sid_:{{.Sid}},
					aid_:{{.Aid}},
					cid_:id,
			    	},
		          error:function(jqXHR, textStatus, errorThrown){
		            if(textStatus=="timeout"){
		              document.getElementById("botinfo").innerHTML=("提交点赞超时，请稍后再提交...");
		            }else{
		              document.getElementById("botinfo").innerHTML=("提交点赞失败!");
		            }
		          },
		          success:function(msg){
		          	if ("[0]" != msg.substr(0,3)) {
						document.getElementById("botinfo").innerHTML=(msg);
		          	} else {
						document.getElementById("botinfo").innerHTML=("你的点赞已经成功!请不要重复点赞。");
						document.getElementById("c"+id).innerHTML=(times+1)
		          	}
		          }
		        });
			}
    </script>
    
    {{if .CanReplay}}
    <p class="h5">你的回应 ...... (提示：字数不能超过1000)<label class="btn">
		<input id="anonymity" type="checkbox" {{.Check}} autocomplete="off"> 匿名发表
        </label></p>
    <div id="write">
    <textarea id="text" name="content" rows="8" style="width:100%;"></textarea>
    </div>
   
	<script>
	var ke
    KindEditor.ready(function(K) {
        ke = K.create('#text', {
        pasteType:1,
        allowImageUpload:false,
        allowFlashUpload:false,
        allowMediaUpload:false,
        allowFileUpload:false,
        cssData: 'body {font-family: "微软雅黑"; font-size: 14px;}',
        items:[  'source', '|', 'preview', 'code', '|', 'justifyleft', 'justifycenter', 'justifyright',
    'justifyfull','selectall', '|',
    'formatblock', 'fontsize', 'removeformat','|', 'forecolor', 'bold',
    'italic', 'underline', '|', 'image','link', '|'],
	afterCreate:function () {
        this.sync();                  
        },
        afterChange:function() {
        this.sync();
        }
    });
    });

	var answerId = -1
	function test(name,id){
		ke.html("<p>@<strong>(#"+id+"楼) "+name+"</strong>&nbsp;&nbsp;</p>");
		answerId = id
	}
	function comment() {
		
		var any = document.getElementById("anonymity");
		var anonymity = false;
		if(any.checked)
		{
			anonymity = true;
		}
		var text = document.getElementById("text").value;
		if (text.length < 1) {
			document.getElementById("botinfo").innerHTML=("错误：评论为空，请输入评论！");
			return 
		} else if (text.length > 2000) {
			document.getElementById("botinfo").innerHTML=("提升：评论不能超过2000个字，当前字数:" + text.length);
			return
		}
		var btn = $("#commit"); 			
		$.ajax({
		          async:true,
		          cache:false,
		          timeout:10000,
		          type:"POST",
		          url:"/comment",
		          data:{
		          	sid_:{{.Sid}},
					aid_:{{.Aid}},
					uid_:{{.UserId}},
					answer_:answerId,
					anonymity_:anonymity,
			        comment_:text,
			    	},
		          error:function(jqXHR, textStatus, errorThrown){
		            if(textStatus=="timeout"){
		              document.getElementById("botinfo").innerHTML=("提交点评超时，请稍后再提交...");
		            }else{
		              document.getElementById("botinfo").innerHTML=("提交点评失败!");
		            }
		          },
		          success:function(msg){
		          	if ("[0]" != msg.substr(0,3)) {
						document.getElementById("botinfo").innerHTML=(msg);
						
		          	} else{
					    btn.attr("disabled", true);
						document.getElementById("botinfo").innerHTML=("你的评论已经成功发布!请不要重复提交。");
						window.location.href=msg.substr(3)
		          	}
		          }
		        });
			}
	</script>
	<button type="button" class="btn btn-default btn-sm" style="float:right;" id="commit" onclick="comment()">加上去</button>
	<p id="botinfo" class="alert alert-info">网站提示：点击右边按钮提交评论！</p>
	<script>
	if ("游客" == getUser()) {
		document.getElementById("botinfo").innerHTML=("您还没登录，不能留言，请先登录...");
	}
	</script>
	{{else}}
	<p class="h5">抱歉，评论已经超过最大限制数，不能再留言</p>
	{{end}}
</div>
</div>
</div>

</body>
</html>

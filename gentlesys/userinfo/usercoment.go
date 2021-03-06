package userinfo

import (
	"gentlesys/store"
	"os"
	"strings"

	"github.com/golang/protobuf/proto"
)

//用户评论管理。也是使用.proto结构进行管理
//用户发布的话题相关的功能在此
//相关的功能在此
type Comment struct {
	Fd *os.File
	//不需要锁，因为只有用户自己才能操作自己的几率，不存在并发的可能性
}

//禁用一条评论。
func (c *Comment) DisableOneComment(subId int, aid int, pageNums int, id int, sobj *store.Store) (bool, int) {

	if srcData, ok := c.ReadCommentBlockByIndex(pageNums, sobj); ok && srcData != nil {

		for _, v := range srcData.Usercommentdata {
			if int(*v.SubId) == subId && int(*v.Aid) == aid && int(*(v.Commentdata.Id)) == id {
				//找到并屏蔽
				if v.Commentdata.IsDel != nil && *(v.Commentdata.IsDel) {
					//已经是禁用的

					return false, 1
				}
				v.Commentdata.IsDel = proto.Bool(true)
				mdata, err := proto.Marshal(srcData)
				if err != nil {
					panic(err)
				}
				//fmt.Printf("第%d楼用户中心已经删除回复\n", id)

				return sobj.UpdateBlockToStore(mdata, pageNums)
			}
		}
		//fmt.Printf("退出第%d楼用户中心已经删除回复\n", id)
	} else {
		//fmt.Printf("第%d楼用户中心没有删除回复\n", id)
	}
	return false, 0
}

//修改一条作者回复
func (c *Comment) UpdateOneCommentAnswer(subId int, aid int, pageNums int, id int, answer string, sobj *store.Store) (bool, int) {

	if srcData, ok := c.ReadCommentBlockByIndex(pageNums, sobj); ok && srcData != nil {

		for _, v := range srcData.Usercommentdata {
			if int(*v.SubId) == subId && int(*v.Aid) == aid && int(*(v.Commentdata.Id)) == id {
				//找到并修改
				answer = strings.Replace(answer, "@", "作者回复@", 1)
				v.Commentdata.Answer = proto.String(answer)

				mdata, err := proto.Marshal(srcData)
				if err != nil {
					panic(err)
				}
				return sobj.UpdateBlockToStore(mdata, pageNums)
			}
		}
		//fmt.Printf("退出第%d楼用户中心已经删除回复\n", id)
	}
	return false, 0
}

//增加一条发帖，返回最后评论页面index
func (c *Comment) AddOneUserComment(data *store.UserCommentData, sobj *store.Store) (bool, int) {

	srcData, ok := c.ReadCurUserCommentBlock(sobj)
	if !ok {
		return false, 0
	}
	if srcData == nil {
		srcData = &store.UserComments{}
		srcData.Usercommentdata = []*store.UserCommentData{data}
		//fmt.Printf("这是用户中心块的第一条评论\n")
	} else {
		srcData.Usercommentdata = append(srcData.Usercommentdata, data)
		//fmt.Printf("这不是用户中心块的第一条评论\n")
	}

	mdata, err := proto.Marshal(srcData)
	if err != nil {
		panic(err)
	}

	return sobj.UpdateTailBlockToStore(mdata, len(srcData.Usercommentdata))

}

//读取指定块的评论内容
func (c *Comment) ReadCommentBlockByIndex(blockNums int, sobj *store.Store) (*store.UserComments, bool) {

	if buf, ok := sobj.GetOnePageContent(&blockNums); ok && buf != nil {
		m2 := &store.UserComments{}
		proto.Unmarshal(*buf, m2) //反序列化
		return m2, true
	} else if ok {
		//第一次读到空
		return nil, true
	} else {
		return nil, false
	}
}

//读当前的用户帖子块，每个块包含OnePageCommentNum条记录
func (c *Comment) ReadCurUserCommentBlock(sobj *store.Store) (*store.UserComments, bool) {
	return c.ReadCommentBlockByIndex(-1, sobj)
}

//获取一页帖子
func (c *Comment) GetOnePageComment(pageNums int, sobj *store.Store) (*[]*store.UserCommentData, bool) {

	if buf, ok := sobj.GetOnePageContent(&pageNums); ok && buf != nil {
		m2 := &store.UserComments{}
		proto.Unmarshal(*buf, m2) //反序列化
		return &m2.Usercommentdata, true
	} else if ok {
		return nil, true
	} else {
		return nil, false
	}
}
